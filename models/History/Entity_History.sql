{{ config(materialized='table') }}
SELECT DISTINCT CAST(ReportDateRange AS DATE) AS AsOfDate
	,f.GPFundId
	,e.EntityId
	,CAST(u.MarketValueDate AS DATE) AS MarketValueDate
	,u.MarketValueLocal
	,u.CurrentStatus AS Status
	,u.TotalProceedsLocal
	,u.TotalProceedsClient
	,u.TotalCostLocal
	,u.TotalCostClient
	,u.RemainingCostClient
	,u.RemainingCostLocal
FROM [ETL].[CompanyReport] AS u
LEFT OUTER JOIN [dbo].[GPFund] AS f ON f.OrgGuid = u.OrganizationGUID
LEFT OUTER JOIN [dbo].[Entity] AS e ON e.EntityGuid = u.EntityGuid
WHERE u.EntityGUID IS NOT NULL