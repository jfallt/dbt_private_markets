{{ config(materialized='table') }}
SELECT p.PortfolioInvestmentId
	,CONVERT(DATE, mr.CashFlowValuationDate) AS CashFlowDate
	,CONVERT(MONEY, mr.FundingClient) AS FundingClient
	,CONVERT(MONEY, mr.AdditionalFeesClient) AS AdditionalFeesClient
	,CONVERT(MONEY, mr.CashDistributionsClient) AS CashDistributionsClient
	,CONVERT(MONEY, mr.StockDistributionsClient) AS StockDistributionsClient
	,CONVERT(MONEY, mr.AmountRecallableClient) AS AmountRecallableClient
	,CONVERT(MONEY, mr.FundingLocal) AS FundingLocal
	,CONVERT(MONEY, mr.AdditionalFeesLocal) AS AdditionalFeesLocal
	,CONVERT(MONEY, mr.CashDistributionsLocal) AS CashDistributionsLocal
	,CONVERT(MONEY, mr.StockDistributionsLocal) AS StockDistributionsLocal
	,CONVERT(MONEY, mr.AmountRecallableLocal) AS AmountRecallableLocal
	,p.Exclude
FROM [ETL].[ManagerReport] mr
INNER JOIN {{ref('PortfolioInvestment')}} p ON p.[InvestmentGUID] = mr.[InvestmentGUID]
WHERE mr.OrganizationType = 'Partnership'
	AND (
		NOT (
			mr.FundingClient = 0
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
