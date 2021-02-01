{{ config(materialized='table') }}

-- Treat records with a non zero valuation OR all Zeros (valuations and cash flows) as valuations
SELECT p.PortfolioID
	,CONVERT(date, mr.CashFlowValuationDate) as CashFlowValuationDate
	,CONVERT(money, mr.ReportedValuationLocal) as ReportedValuationLocal
FROM [ETL].[ManagerReport] mr
INNER JOIN {{ref('Portfolio')}} p ON p.[ServiceProviderName] = mr.[FLAGFundName]
WHERE mr.OrganizationType = 'Fund Of Funds'
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