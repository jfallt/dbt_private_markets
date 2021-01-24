{{ config(materialized='table') }}

SELECT DISTINCT HASHBYTES('MD5', [OrgGUID]) AS GPFundID
	,NULL AS ShortName
	,NULL AS DisplayName
	,[FundName] AS ServiceProviderName
	,[OrgGUID]
	,[FundLocalCurrency] AS LocalCurrencyCode
	,CONVERT(BIT, 0) AS Exclude
	,CONVERT(BIT, 0) AS SideFund
	,[Geography]
	,[Industry]
	,[ForeignBased]
FROM [ETL].[ManagerReport]
WHERE OrganizationType = 'Partnership'