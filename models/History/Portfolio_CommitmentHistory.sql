-- Sum results of portfolio investment history by quarter to the portfolio level
SELECT p.PortfolioID
	,sum(EffectiveCommitmentAmountLocal) AS CommitmentAmountLocal
	,sum(EffectiveAdjustedCommitmentAmountLocal) AS AdjustedCommitmentAmountLocal
	,sum(EffectiveCommitmentAmountClient) AS [CommitmentAmountClient]
	,sum(EffectiveAdjustedCommitmentAmountClient) AS AdjustedCommitmentAmountClient
FROM {{ref('PortfolioInvestment_CommitmentHistory')}} pih
INNER JOIN {{ref('PortfolioInvestment')}} poi ON poi.PortfolioInvestmentID = pih.PortfolioInvestmentId
INNER JOIN {{ref('Portfolio')}} p ON p.PortfolioID = poi.portfolioId
GROUP BY p.PortfolioID
	,asofdate