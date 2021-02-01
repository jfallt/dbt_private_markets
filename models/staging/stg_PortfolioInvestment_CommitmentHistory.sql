SELECT p.PortfolioInvestmentID
	,ch.PortfolioId
	,ch.GPFundId
	,Portfolio
	,Investment
	,EffectiveDate
	,CommitmentAmountLocal
	,AdjustedCommitmentAmountLocal
FROM {{ref('stg_CommitmentHistoryProcessed') }} ch
LEFT JOIN {{ref('PortfolioInvestment') }} p ON p.PortfolioID = ch.PortfolioId
	AND p.GPFundID = ch.GPFundId
WHERE Portfolio <> Investment
	AND ch.PortfolioId IS NOT NULL