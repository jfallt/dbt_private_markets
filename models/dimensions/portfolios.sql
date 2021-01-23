select distinct 
	[Short Name] as ShortName,
	null as DisplayName,
	[FLAG Fund Name] as ServiceProviderName,
	[FLAG Fund Local Currency] as LocalCurrencyCode,
	null as FundStrategy
from [dbo].[manager_report_data]
where [Flag Fund Name] like '%Net,%'