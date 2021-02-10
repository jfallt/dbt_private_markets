{{config(materialized = 'table') }}
WITH entities_rn AS (
		SELECT [EntityGUID]
			,[EntityName]
			,[DomicileCity]
			,[DomicileStateProvince]
			,[DomicileCountry]
			,[PrincipalOperationsCountry]
			,[UserDescription]
			,[StockSymbol]
			,[PublicPrivateStatus]
			,CASE 
				WHEN (
						IsNull(IndustryVEICCode, - 1) IN (
							0
							,300
							,400
							,500
							)
						)
					THEN CONVERT(BIT, 0)
				ELSE CONVERT(BIT, 1)
				END AS IsInvestable
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
		FROM (
			SELECT *
			FROM [ETL].[CompanyReport]
			
			UNION
			
			SELECT *
			FROM etl.CompanyReportCurrent
			) a
		WHERE [EntityGUID] IS NOT NULL
		)

SELECT HASHBYTES('MD5', [EntityGUID]) AS EntityID
	,[EntityGUID]
	,[EntityName]
	,[PublicPrivateStatus]
	,[IsInvestable]
	,[DomicileCity]
	,[DomicileStateProvince]
	,[DomicileCountry]
	,[PrincipalOperationsCountry]
	,[UserDescription]
	,[StockSymbol]
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
