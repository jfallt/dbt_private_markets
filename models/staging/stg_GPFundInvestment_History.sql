{{ config(materialized='table') }}

SELECT DISTINCT p.PeriodId
	,i.GPFundInvestmentId
	,f.GPFundId
	,e.EntityId
	,u.CurrentStatus AS [Status]
	,CAST(u.MarketValueDate AS DATE) AS MarketValueDate
	,CONVERT(MONEY, u.MarketValueLocal) AS MarketValueLocal
	,CONVERT(MONEY, u.TotalProceedsLocal) AS TotalProceedsLocal
	,CONVERT(MONEY, u.TotalCostLocal) AS TotalCostLocal
	,CONVERT(MONEY, u.RemainingCostLocal) AS RemainingCostLocal
FROM [ETL].[CompanyReport] AS u
INNER JOIN {{ref('Period')}} p ON p.AsOfDate = u.ReportDateRange
LEFT JOIN {{ref('GPFund')}} AS f ON f.OrgGuid = u.OrganizationGUID
LEFT JOIN {{ref('Entity')}} AS e ON e.EntityGuid = u.EntityGuid
LEFT JOIN {{ref('GPFundInvestment')}} AS i ON i.EntityId = e.EntityId
	AND i.GPFundid = f.GPFundid
WHERE u.EntityGUID IS NOT NULL