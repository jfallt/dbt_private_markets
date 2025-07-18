{{ config(materialized='table') }}
SELECT p.PortfolioId
	,mr.CashFlowValuationDate as CashFlowDate
	,mr.FundingClient
	,mr.AdditionalFeesClient
	,mr.CashDistributionsClient
	,mr.StockDistributionsClient
	,mr.AmountRecallableClient
	,mr.FundingLocal
	,mr.AdditionalFeesLocal
	,mr.CashDistributionsLocal
	,mr.StockDistributionsLocal
	,mr.AmountRecallableLocal
FROM [ETL].[ManagerReport] mr
INNER JOIN {{ref('Portfolio')}} p ON p.[ServiceProviderName] = mr.[FLAGFundName]
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
