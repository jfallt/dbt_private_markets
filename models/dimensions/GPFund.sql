{{config(materialized = 'table')}}
{{ 
    config(
      {"materialized":"table",
		"pre-hook": "{{ drop_all_indexes_on_table() }}",
      "post-hook": [
         "{{ create_nonclustered_index(columns = ['GPFundId']) }}"
	 ]
    }) 
}}

SELECT DISTINCT HASHBYTES('MD5', [OrgGUID]) AS GPFundID
	,NULL AS ShortName
	,NULL AS DisplayName
	,[FundName] AS ServiceProviderName
	,[OrgGUID]
	,CONVERT(CHAR(3), [FundLocalCurrency]) AS LocalCurrencyCode
	,[FundSizeLocal]
	,CONVERT(BIT, 0) AS Exclude
	,CONVERT(BIT, 0) AS SideFund
	,[Geography]
	,[Industry]
	,[ForeignBased]
FROM [ETL].[ManagerReport]
WHERE OrganizationType = 'Partnership'