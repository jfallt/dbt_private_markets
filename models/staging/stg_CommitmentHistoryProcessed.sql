WITH investmentGUID
AS (
	SELECT DISTINCT [GroupBy1] AS Portfolio
		,investment
		,GlobalIdentifier
	FROM [ETL].[CommitmentListWithGUID]
	WHERE globalidentifier IS NOT NULL
	)
SELECT isnull(ff1.PortfolioId, ff2.PortfolioId) AS PortfolioId
	--,isnull(ff1.ServiceProviderName, ff2.ServiceProviderName) AS ServiceProviderName
	,COALESCE(poi.GPFundID, gpf.GPFundID, gpf2.GPFundID) AS GPFundId
	,ch.Portfolio
	,ch.Investment
	,CAST(ch.[EffectiveDate] AS DATE) AS EffectiveDate
	,CONVERT(MONEY, ch.[CommitmentAmountLocal]) AS [CommitmentAmountLocal]
	,CONVERT(MONEY, ch.[AdjustedCommitmentAmountLocal]) AS [AdjustedCommitmentAmountLocal]
	,ch.[LocalCurrency]
FROM [ETL].CommitmentHistory ch
LEFT JOIN investmentGUID ig ON ig.Portfolio = ch.Portfolio
	AND ig.investment = ch.Investment
LEFT JOIN {{ref('PortfolioInvestment')}} poi ON poi.GlobalIdentifier = ig.GlobalIdentifier
LEFT JOIN {{ref('Portfolio')}} ff1 ON ff1.ServiceProviderName = ch.Portfolio
LEFT JOIN (
	SELECT DISTINCT FlagFundName
		,ShortName
	FROM [ETL].[ManagerReport]
	) b ON b.FlagFundName = ch.Portfolio
	AND ff1.ServiceProviderName IS NULL
LEFT JOIN {{ref('Portfolio')}} ff2 ON ff2.ShortName = b.ShortName
LEFT JOIN {{ref('GPFund')}} gpf ON gpf.ServiceProviderName = ch.Investment
LEFT JOIN (
	SELECT DISTINCT OrgGuid
		,FundName
	FROM [ETL].[ManagerReport]
	) b2 ON b2.FundName = ch.Investment
	AND gpf.GPFundID IS NULL
LEFT JOIN {{ref('GPFund')}} gpf2 ON gpf2.OrgGuid = b2.OrgGUID