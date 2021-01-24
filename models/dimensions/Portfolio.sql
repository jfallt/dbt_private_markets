{{ config(materialized='table') }}

select distinct 
	HASHBYTES ( 'MD5', [FLAGFundName]) as PortfolioID,
	[ShortName] as ShortName,
	null as DisplayName,
	[FLAGFundName] as ServiceProviderName,
	[FLAGFundLocalCurrency] as LocalCurrencyCode,
	null as FundStrategy
from [ETL].[ManagerReport]
where OrganizationType = 'Fund of Funds'