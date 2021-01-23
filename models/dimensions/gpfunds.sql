select distinct
	null as ShortName,
	null as DisplayName,
	[Fund Name] as ServiceProviderName,
	[Org GUID],
	[Fund Local Currency] as LocalCurrencyCode,
	CONVERT(bit, 0) as Exclude,
	CONVERT(bit, 0) as SideFund,
	[Geography],
	[Industry],
	[Foreign Based] as ForeignBased
from [dbo].[manager_report_data]
