{{config(materialized = 'table')}}
WITH reporting_dates
AS (
	SELECT DISTINCT cast([ReportDateRange] AS DATE) AS AsOfDate
	FROM (
		SELECT *
		FROM [ETL].[CompanyReport]
		
		UNION
		
		SELECT *
		FROM [ETL].[CompanyReportCurrent]
		) a
	)
SELECT ROW_NUMBER() OVER (
		ORDER BY AsOfDate
		) AS PeriodId
	,AsOfDate
FROM reporting_dates