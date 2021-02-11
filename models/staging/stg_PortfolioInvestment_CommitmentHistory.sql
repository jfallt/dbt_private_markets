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


-- =============================================
-- Description:	Convert commitment history
-- into effective commitment & adjusted commitment
-- by quarter
-- =============================================

WITH PortfolioInvestmentCommitmentHistory as 
(SELECT p.PortfolioInvestmentID
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
),

 CommitByQuarter -- convert the staged commitment history into quarterly data
AS (
	SELECT ph.PortfolioInvestmentId
		,ph.[PortfolioId]
		,ph.GPFundId
		,pd.asofdate
		,ph.EffectiveDate
		,ph.AdjustedCommitmentAmountLocal
		,ph.CommitmentAmountLocal
		,ROW_NUMBER() OVER (
			PARTITION BY ph.PortfolioId
			,ph.GPFundId
			,AsOfDate ORDER BY [EffectiveDate] DESC
			) AS rn
	FROM Period pd
	CROSS APPLY (
		SELECT *
		FROM PortfolioInvestmentCommitmentHistory
		) AS ph
	WHERE ph.EffectiveDate <= pd.[AsOfDate]
	)

SELECT cbq.AsOfDate
	,cbq.PortfolioInvestmentId
	,QFFIFunding.IsFunded
	,QFFIFunding.EffectiveAdjustedCommitmentAmountClient
	,QFFIFunding.EffectiveAdjustedCommitmentAmountLocal
	,QFFIFunding.EffectiveCommitmentAmountClient
	,QFFIFunding.EffectiveCommitmentAmountLocal
FROM CommitByQuarter cbq
INNER JOIN {{ref('Portfolio')}} p ON p.PortfolioID = cbq.PortfolioId
INNER JOIN {{ref('GPFund')}} gpf ON gpf.GPFundId = cbq.GPFundId
CROSS APPLY (
	SELECT dbo.fnFXRate(gpf.LocalCurrencyCode, p.LocalCurrencyCode, cbq.AsOfDate) AS FxRate
	) AS ComputedValues
CROSS APPLY (
	-- valuation dates
	SELECT MAX(piv.ValuationDate) AS LatestValuationDate
	FROM PortfolioInvestment_Valuations AS piv
	WHERE piv.PortfolioInvestmentId = cbq.PortfolioInvestmentId
		AND piv.ValuationDate <= cbq.AsOfDate
	) AS PIvaluationData
OUTER APPLY dbo.fnPortfolioInvestmentCashFlowData(cbq.PortfolioInvestmentId, PIvaluationData.LatestValuationDate) AS PICFD -- cash flow data
CROSS APPLY (
	-- calculated effective and effective adjusted commitmentment
	SELECT FundingStatus.IsFunded
		,CASE FundingStatus.IsFunded
			WHEN 1
				THEN cbq.CommitmentAmountLocal
			ELSE 0
			END AS EffectiveCommitmentAmountLocal
		,CASE FundingStatus.IsFunded
			WHEN 1
				THEN cbq.AdjustedCommitmentAmountLocal
			ELSE 0
			END AS EffectiveAdjustedCommitmentAmountLocal
		,CASE FundingStatus.IsFunded
			WHEN 0
				THEN 0
			ELSE Convert(MONEY, (cbq.CommitmentAmountLocal - ((IsNull(PICFD.TotalFundingLocal, 0) * - 1) - IsNull(PICFD.TotalAmountRecallableLocal, 0))) / ComputedValues.FxRate) + ((IsNull(PICFD.TotalFundingClient, 0) * - 1) - IsNull(PICFD.TotalAmountRecallableClient, 0))
			END AS EffectiveCommitmentAmountClient
		,CASE FundingStatus.IsFunded
			WHEN 0
				THEN 0
			ELSE Convert(MONEY, (cbq.AdjustedCommitmentAmountLocal - ((IsNull(PICFD.TotalFundingLocal, 0) * - 1) - IsNull(PICFD.TotalAmountRecallableLocal, 0))) / ComputedValues.FxRate) + ((IsNull(PICFD.TotalFundingClient, 0) * - 1) - IsNull(PICFD.TotalAmountRecallableClient, 0))
			END AS EffectiveAdjustedCommitmentAmountClient
	FROM (
		-- determine funding status based on the first cash flow date
		SELECT CASE 
				WHEN PICFD.MinFundingDate IS NULL
					THEN Convert(BIT, 0)
				WHEN PICFD.MinFundingDate > cbq.AsOfDate
					THEN Convert(BIT, 0)
				ELSE Convert(BIT, 1)
				END AS IsFunded
		) AS FundingStatus
	) AS QFFIFunding
WHERE rn = 1