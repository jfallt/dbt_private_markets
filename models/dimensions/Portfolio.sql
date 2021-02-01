{{config(materialized = 'table')}}
{{ 
    config(
      {"materialized":"table",
		"pre-hook": "{{ drop_all_indexes_on_table() }}",
      "post-hook": [
         "{{ create_nonclustered_index(columns = ['PortfolioID']) }}"
	 ]
    }) 
}}

select distinct 
	HASHBYTES ( 'MD5', [FLAGFundName]) as PortfolioID,
	[ShortName] as ShortName,
	null as DisplayName,
	[FLAGFundName] as ServiceProviderName,
	CONVERT(CHAR(3), [FLAGFundLocalCurrency])  as LocalCurrencyCode,
	null as FundStrategy
from [ETL].[ManagerReport]
where OrganizationType = 'Fund of Funds'