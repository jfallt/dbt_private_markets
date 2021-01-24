{{ config(materialized='table') }}

select distinct
	HASHBYTES ( 'MD5', [OrgGUID]) as GPFundID,
	null as ShortName,
	null as DisplayName,
	[FundName] as ServiceProviderName,
	[OrgGUID],
	[FundLocalCurrency] as LocalCurrencyCode,
	CONVERT(bit, 0) as Exclude,
	CONVERT(bit, 0) as SideFund,
	[Geography],
	[Industry],
	[ForeignBased]
from [ETL].[ManagerReport]