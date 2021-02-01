{{config(materialized = 'table')}}
WITH entities_rn
AS (
	SELECT u.InvestmentAlias
		,f.GPFundId
		,e.EntityId
		,u.[EntityGUID]
		,u.OrganizationGUID
		,cast(u.InvestmentDate AS DATE) AS InvestmentDate
		,cast(u.ExitDate AS DATE) AS ExitDate
		,u.IsNetOtherAssets
		,isnull(u.PreMoneyValuationLocal, 0) AS PreMoneyValuationLocal
		,isnull(u.PreMoneyValuationClient, 0) AS PreMoneyValuationClient
		,ROW_NUMBER() OVER (
			PARTITION BY u.OrganizationGUID
			,u.[EntityGUID] ORDER BY [ReportDateRange] DESC
			) AS rn
	FROM [ETL].[CompanyReport] AS u
	LEFT JOIN {{ref('GPFund')}} AS f ON f.OrgGUID = u.OrganizationGUID
	LEFT JOIN {{ref('Entity')}} AS e ON e.EntityGUID = u.EntityGUID
	WHERE u.[EntityGUID] IS NOT NULL
	)

SELECT HASHBYTES('MD5', CONCAT(OrganizationGUID,[EntityGUID])) AS GPFundInvestmentId
	,GPFundId
	,EntityId
	,cast(InvestmentDate AS DATE) AS InvestmentDate
	,cast(ExitDate AS DATE) AS ExitDate
	,IsNetOtherAssets
	,PreMoneyValuationLocal
	,PreMoneyValuationClient
FROM entities_rn
WHERE rn = 1