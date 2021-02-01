-- Sum results of portfolio investment history by quarter to the portfolio level
SELECT shortname
	,sum(commitmentamountlocal) AS CommitmentAmountLocal
	,sum(adjustedcommitmentamountlocal) AS AdjustedCommitmentAmountLocal
	,sum([CommitmentAmountClient]) AS [CommitmentAmountClient]
	,sum([AdjustedCommitmentAmountClient]) AS AdjustedCommitmentAmountClient
	,asofdate
FROM (
	SELECT pih.*
		,gpf.LocalCurrencyCode
		,gpf.ServiceProviderName
		,p.ShortName
		,CONVERT(MONEY, pih.[CommitmentAmountLocal] / FxRate) AS [CommitmentAmountClient]
		,CONVERT(MONEY, pih.[AdjustedCommitmentAmountLocal] / FxRate) AS AdjustedCommitmentAmountClient
	FROM {{ref('PortfolioInvestment_CommitmentHistory')}} pih
	LEFT JOIN {{ref('GPFund')}} gpf ON gpf.GPFundID = pih.gpfundid
	LEFT JOIN {{ref('Portfolio')}} p ON p.PortfolioID = pih.portfolioId
	CROSS APPLY (
		SELECT dbo.fnFXRate(gpf.LocalCurrencyCode, p.LocalCurrencyCode, asofdate) AS FxRate
		) AS ComputedValues
	WHERE PortfolioInvestmentID IS NOT NULL
	) a
GROUP BY shortname
	,asofdate