{{config(materialized = 'table')}}

SELECT DISTINCT HASHBYTES('MD5', [InvestmentGUID]) AS PortfolioInvestmentID
	,mr.InvestmentGUID
	,mr.GlobalIdentifier
	,p.PortfolioID
	,gpf.GPFundID
	,CONVERT(BIT, mr.Secondary) AS Secondary
	,CONVERT(BIT, mr.Liquidated) AS Liquidated
	,CONVERT(DATE, mr.LiquidationDate) AS LiquidationDate
	,CONVERT(BIT, 0) AS Exclude
	,CONVERT(BIT, 0) AS SoldPartnership
	,NULL AS SoldDate
	,CONVERT(DATE, mr.ClosingDate) AS ClosingDate
	,mr.InvestmentName
	,CONVERT(SMALLINT, mr.VintageYear) AS VintageYear
	,mr.[InvestmentType]
FROM [ETL].[ManagerReport] AS mr
INNER JOIN {{ref('Portfolio')}} p ON p.[ShortName] = mr.[ShortName]
INNER JOIN {{ref('GPFund')}}  AS gpf ON gpf.[OrgGUID] = mr.[OrgGUID]
WHERE OrganizationType = 'Partnership'