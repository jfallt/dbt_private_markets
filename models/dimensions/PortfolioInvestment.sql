{{ config(materialized='table') }}

SELECT DISTINCT HASHBYTES('MD5', [InvestmentGUID]) AS PortfolioInvestmentID
	,mr.InvestmentGUID
	,mr.GlobalIdentifier
	,p.PortfolioID
	,gpf.GPFundID
	,mr.Secondary
	,mr.Liquidated
	,mr.LiquidationDate
	,mr.ClosingDate
	,mr.InvestmentName
	,mr.VintageYear
	,mr.[InvestmentType]
FROM [ETL].[ManagerReport] AS mr
INNER JOIN [dbo].[Portfolio] p ON p.[ShortName] = mr.[ShortName]
INNER JOIN [dbo].[GPFund] AS gpf ON gpf.[OrgGUID] = mr.[OrgGUID]
WHERE OrganizationType = 'Partnership'