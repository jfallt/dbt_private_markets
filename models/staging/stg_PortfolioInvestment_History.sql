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
SELECT pih.PortfolioInvestmentID
	,pih.AsOfDate
	,CASE poi.Liquidated
		WHEN 1
			THEN CASE 
					WHEN (poi.LiquidationDate IS NULL)
						THEN -- Should not happen
							CAST(1 AS BIT)
					ELSE CASE 
							WHEN poi.LiquidationDate <= pih.AsOfDate
								OR dbo.fnSameQuarterYear(poi.LiquidationDate, pih.AsOfDate) = 1
								THEN CAST(1 AS BIT)
							ELSE CAST(0 AS BIT)
							END
					END
		ELSE CAST(0 AS BIT)
		END AS LiquidatedAsOfThisQuarter
	,IsNull(FFICFD.TotalFundingClient, 0) * - 1 AS TotalFundingClient
	,IsNull(FFICFD.TotalDistributionsClient, 0) AS TotalDistributionsClient
	,IsNull(FFICFD.ValuationsClient, 0) AS TotalValuationsClient
	,CommitmentHistory.EffectiveCommitmentAmountClient AS TotalEffectiveCommitmentAmountClient
	,CommitmentHistory.EffectiveCommitmentAmountLocal AS TotalEffectiveCommitedAmountLocal
	,CommitmentHistory.EffectiveAdjustedCommitmentAmountClient AS TotalEffectiveAdjustedCommitmentAmountClient
	,CommitmentHistory.EffectiveAdjustedCommitmentAmountLocal AS TotalEffectiveAdjustedCommitmentAmountLocal
	,IsNull(FFICFD.TotalFundingLocal, 0) * - 1 AS TotalFundingLocal
	,IsNull(FFICFD.TotalDistributionsLocal, 0) AS TotalDistributionsLocal
	,IsNull(FFICFD.ValuationsLocal, 0) AS TotalValuationsLocal
	,PIXirr.XirrClient
	,PIXirr.XirrLocal
	,CASE (poi.SoldPartnership)
		WHEN 1
			THEN CASE 
					WHEN poi.LiquidationDate IS NULL
						THEN -- Should not happen
							CAST(1 AS BIT)
					ELSE CASE 
							WHEN poi.LiquidationDate <= pih.AsOfDate
								OR dbo.fnSameQuarterYear(poi.LiquidationDate, pih.AsOfDate) = 1
								THEN CAST(1 AS BIT)
							ELSE CAST(0 AS BIT)
							END
					END
		ELSE CAST(0 AS BIT)
		END AS SoldPartnershipAsOfThisQuarter
	,CASE poi.[Secondary]
		WHEN N'True'
			THEN CommitmentHistory.EffectiveAdjustedCommitmentAmountLocal
		ELSE CommitmentHistory.EffectiveCommitmentAmountLocal
		END AS [TotalSecondaryCommitmentAmountLocal]
	,CASE poi.[Secondary]
		WHEN N'True'
			THEN CommitmentHistory.EffectiveAdjustedCommitmentAmountClient
		ELSE CommitmentHistory.EffectiveCommitmentAmountClient
		END AS [TotalSecondaryCommitmentAmountClient]
FROM {{ref('PortfolioInvestment_CommitmentHistory')}} AS pih
INNER JOIN {{ref('PortfolioInvestment')}} poi ON poi.PortfolioInvestmentID = pih.PortfolioInvestmentID
INNER JOIN {{ref('Portfolio')}} p ON p.PortfolioID = poi.PortfolioID
INNER JOIN {{ref('GPFund')}} gpf ON gpf.GPFundID = poi.GPFundID
CROSS APPLY (
	SELECT ffiv.ValuationDate AS LatestValuationDate
	FROM {{ref('PortfolioInvestment_Valuations')}} AS ffiv
	WHERE ffiv.PortfolioInvestmentId = pih.PortfolioInvestmentId
		AND ffiv.ValuationDate = pih.AsOfDate
	) AS FFIValuationData
OUTER APPLY dbo.fnPortfolioInvestmentCashFlowData(pih.PortfolioInvestmentID, FFIValuationData.LatestValuationDate) AS FFICFD
CROSS APPLY (
	SELECT dbo.XIRR(picfs.CashFlowDate, picfs.CashFlowAmountLocal, NULL) AS XirrLocal
		,dbo.XIRR(picfs.CashFlowDate, picfs.CashFlowAmountClient, NULL) AS XirrClient
	FROM dbo.fnPortfolioInvestmentNetCashFlows(pih.PortfolioInvestmentID, pih.AsOfDate, FFICFD.ValuationsLocal, FFICFD.ValuationsClient) AS picfs
	WHERE picfs.CashFlowDate IS NOT NULL
	) AS PIXirr
OUTER APPLY (
	SELECT *
	FROM {{ref('PortfolioInvestment_CommitmentHistory')}} pch
	WHERE pch.AsOfDate = pih.AsOfDate
		AND pch.PortfolioInvestmentId = pih.PortfolioInvestmentId
	) CommitmentHistory