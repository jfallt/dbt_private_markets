{{config(materialized = 'table')}}
WITH reporting_dates
AS (
	SELECT DISTINCT cast([ReportDateRange] AS DATE) AS AsOfDate
	FROM [ETL].[CompanyReport]
	)
SELECT ROW_NUMBER() OVER (
		ORDER BY AsOfDate
		) AS PeriodId
	,AsOfDate
FROM reporting_dates