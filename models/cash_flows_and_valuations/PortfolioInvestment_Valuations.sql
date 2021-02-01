{{ config(materialized='table') }}
{{ 
    config(
      {"materialized":"table",
		"pre-hook": "{{ drop_all_indexes_on_table() }}",
      "post-hook": [
         "{{ create_nonclustered_index(columns = ['PortfolioInvestmentId', 'ValuationDate']) }}"
	 ]
    }) 
}}

-- Treat records with a non zero valuation OR all Zeros (valuations and cash flows) as valuations
WITH portfolioInvestmentValuations
AS (
	SELECT p.PortfolioInvestmentId
		,p.GPFundID
		,p.PortfolioID
		,CONVERT(DATE, mr.CashFlowValuationDate) AS ValuationDate
		,CONVERT(MONEY, mr.ReportedValuationLocal) AS ReportedValuationLocal
	FROM [ETL].[ManagerReport] mr
	INNER JOIN {{ref('PortfolioInvestment')}}  p ON p.[InvestmentGUID] = mr.[InvestmentGUID]
	WHERE mr.OrganizationType = 'Partnership'
		AND mr.ReportedValuationLocal <> 0
		OR (
			mr.ReportedValuationLocal = 0
			AND mr.FundingClient = 0
			AND mr.AdditionalFeesClient = 0
			AND mr.CashDistributionsClient = 0
			AND mr.StockDistributionsClient = 0
			AND mr.FundingLocal = 0
			AND mr.AdditionalFeesLocal = 0
			AND mr.CashDistributionsLocal = 0
			AND mr.AmountRecallableClient = 0
			AND mr.AmountRecallableLocal = 0
			AND mr.StockDistributionsLocal = 0
			)
	)
-- Convert local currencies to client according to portfolios local currency code
SELECT piv.PortfolioInvestmentID
	,piv.ValuationDate
	,piv.ReportedValuationLocal
	,CONVERT(MONEY, piv.ReportedValuationLocal / ComputedValues.FxRate) AS ReportedValuationClient
	,CASE 
		WHEN prd.periodid IS NULL
			THEN CONVERT(BIT, 0)
		ELSE CONVERT(BIT, 1)
		END AS IsReportingPeriod
FROM portfolioInvestmentValuations piv
INNER JOIN {{ref('GPFund')}} gpf ON gpf.GPFundID = piv.GPFundID
INNER JOIN {{ref('Portfolio')}} p ON p.PortfolioID = piv.PortfolioID
LEFT JOIN {{ref('Period')}} prd ON prd.asofdate = piv.ValuationDate
CROSS APPLY (
	SELECT dbo.fnFXRate(gpf.LocalCurrencyCode, p.LocalCurrencyCode, piv.ValuationDate) AS FxRate
	) AS ComputedValues