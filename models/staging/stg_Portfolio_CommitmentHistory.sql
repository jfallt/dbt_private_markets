SELECT PortfolioId
	,[EffectiveDate]
	,[CommitmentAmountLocal]
	,[AdjustedCommitmentAmountLocal]
FROM {{ref('stg_CommitmentHistoryProcessed') }}
WHERE Portfolio = Investment
	AND PortfolioId IS NOT NULL