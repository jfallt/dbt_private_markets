{{ config(materialized='table')}}
{{ 
    config(
      {"materialized":"table",
		"pre-hook": "{{ drop_all_indexes_on_table() }}",
      "post-hook": [
         "{{ create_nonclustered_index(columns = ['PortfolioInvestmentId', 'AsOfDate']) }}"
	 ]
    }) 
}}

SELECT PICH.PortfolioInvestmentId
	,PICH.IsFunded
	,PICH.AsOfDate 
	,PICH.EffectiveCommitmentAmountLocal
	,PICH.EffectiveCommitmentAmountClient
	,PICH.EffectiveAdjustedCommitmentAmountLocal
	,PICH.EffectiveAdjustedCommitmentAmountClient
	,PICH.EffectiveCommitmentAmountLocal - IsNull(prevPICH.EffectiveCommitmentAmountLocal, 0) AS EffectiveCommitedAmountLocal
	,PICH.EffectiveCommitmentAmountClient - ISNULL(prevPICH.EffectiveCommitmentAmountClient, 0) AS EffectiveCommitedAmountClient
	,CASE (poi.[Secondary])
		WHEN N'True'
			THEN PICH.EffectiveAdjustedCommitmentAmountLocal - IsNull(prevPICH.EffectiveAdjustedCommitmentAmountLocal, 0)
		ELSE PICH.EffectiveCommitmentAmountLocal - IsNull(prevPICH.EffectiveCommitmentAmountLocal, 0)
		END AS [SecondaryCommitedAmountLocal]
	,CASE (poi.[Secondary])
		WHEN N'True'
			THEN PICH.EffectiveAdjustedCommitmentAmountClient - IsNull(prevPICH.EffectiveAdjustedCommitmentAmountClient, 0)
		ELSE PICH.EffectiveCommitmentAmountClient - IsNull(prevPICH.EffectiveCommitmentAmountClient, 0)
		END AS [SecondaryCommitedAmountClient]
FROM {{ref('stg_PortfolioInvestment_CommitmentHistory')}} PICH
INNER JOIN {{ref('PortfolioInvestment')}} poi on poi.PortfolioInvestmentID = pich.PortfolioInvestmentId
OUTER APPLY (
	SELECT *
	FROM {{ref('stg_PortfolioInvestment_CommitmentHistory')}} PICH2
	WHERE pich2.PortfolioInvestmentId = pich.PortfolioInvestmentId
		AND [dbo].[fnPreviousQuarterEndDate](pich.AsOfDate) = pich2.AsOfDate
	) prevPICH