{{ config(materialized='table') }}

WITH entities_rn as (
		SELECT [EntityGUID]
		,[EntityName]
		,[DomicileCity]
		,[DomicileStateProvince]
		,[DomicileCountry]
		,[PrincipalOperationsCountry]
		,[UserDescription]
		,[StockSymbol]
		,[PublicPrivateStatus]
		,[IndustryICBIndustry]
		,[IndustryVEIC10Category]
		,[IndustryVEIC100Category]
		,[IndustryVEIC1000Category]
		,[IndustryVEICCode]
		,[IndustryVEICName]
		,[IndustryICBSupersector]
		,[IndustryICBSector]
		,[IndustryICBSubsector]
		,[IndustryICBSubsectorCode]
		,ROW_NUMBER() OVER (
			PARTITION BY [EntityGUID] ORDER BY [ReportDateRange] DESC
			) AS rn
	FROM [ETL].[CompanyReport]
	WHERE [EntityGUID] IS NOT NULL
)

SELECT HASHBYTES ( 'MD5', [EntityGUID]) as EntityID
	,[EntityGUID]
	,[EntityName]
	,[DomicileCity]
	,[DomicileStateProvince]
	,[DomicileCountry]
	,[PrincipalOperationsCountry]
	,[UserDescription]
	,[StockSymbol]
	,[PublicPrivateStatus]
	,[IndustryVEIC10Category]
	,[IndustryVEIC100Category]
	,[IndustryVEIC1000Category]
	,[IndustryVEICCode]
	,[IndustryVEICName]
	,[IndustryICBIndustry]
	,[IndustryICBSupersector]
	,[IndustryICBSector]
	,[IndustryICBSubsector]
	,[IndustryICBSubsectorCode]
FROM entities_rn
WHERE rn = 1