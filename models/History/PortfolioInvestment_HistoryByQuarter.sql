WITH CommitByQuarter
AS (
	SELECT ph.PortfolioInvestmentId
		,ph.[PortfolioId]
		,ph.GPFundId
		,TimePeriod.asofdate
		,ph.EffectiveDate
		,ph.AdjustedCommitmentAmountLocal
		,ph.CommitmentAmountLocal
		,ROW_NUMBER() OVER (
			PARTITION BY ph.PortfolioId
			,ph.GPFundId
			,AsOfDate ORDER BY [EffectiveDate] DESC
			) AS rn
	FROM {{ref('PortfolioInvestment_History')}} ph
	CROSS APPLY (
		SELECT *
		FROM {{ref('Period')}} pd
		WHERE ph.EffectiveDate <= pd.[AsOfDate]
		) AS TimePeriod
	)
SELECT PortfolioInvestmentId
	,PortfolioId
	,GPFundId
	,AsOfDate
	,CommitmentAmountLocal
	,AdjustedCommitmentAmountLocal
FROM CommitByQuarter
WHERE rn = 1
