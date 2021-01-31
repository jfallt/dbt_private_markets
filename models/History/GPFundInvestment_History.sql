{{ config(materialized = 'table') }}
SELECT DISTINCT p.PeriodId
	,i.GPFundInvestmentId
	,f.GPFundId
	,e.EntityId
	,u.CurrentStatus AS [Status]
	,CAST(u.MarketValueDate AS DATE) AS MarketValueDate
	,CONVERT(money, u.MarketValueLocal) as MarketValueLocal
	,CONVERT(money,u.TotalProceedsLocal) as TotalProceedsLocal
	,CONVERT(money,u.TotalCostLocal) as TotalCostLocal
	,CONVERT(money,u.RemainingCostLocal) as RemainingCostLocal
FROM [ETL].[CompanyReport] AS u
INNER JOIN [dbo].[Period] p on p.AsOfDate = u.ReportDateRange
LEFT JOIN [dbo].[GPFund] AS f ON f.OrgGuid = u.OrganizationGUID
LEFT JOIN [dbo].[Entity] AS e ON e.EntityGuid = u.EntityGuid
LEFT JOIN [dbo].[GPFundInvestment] AS i
ON i.EntityId = e.EntityId
	and i.GPFundid = f.GPFundid
WHERE u.EntityGUID IS NOT NULL