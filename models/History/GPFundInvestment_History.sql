{{ config(materialized='table') }}
--newInvestmentThreshold = 10
SELECT p.AsOfDate
	,fi.GPFundInvestmentId
	,fi.GPFundId
	,fi.EntityId
	,fih.MarketValueLocal
	,fih.TotalCostLocal
	,fih.RemainingCostLocal AS TotalRemainingCostLocal
	,fih.TotalProceedsLocal
	,fih.TotalProceedsLocal - ISNULL(pfih.TotalProceedsLocal, 0) AS TotalRealizationsLocal
	,CASE FIHComputations.IsNewInvestmentForQuarter
		WHEN 1
			THEN fih.TotalCostLocal
		ELSE 0
		END AS TotalNewInvestmentsLocal
	-- Note: this needs to be recalculated with the client currency so new investment treatment is consistent across gross/net
	,CASE 
		WHEN FIHComputations.IsNewInvestmentForQuarter = 0
			AND ABS(FIHComputations.QuarterlyChangeInTotalCostLocal) > 10
			OR (
				FIHComputations.CurrentQuarterIsZero = 1
				AND FIHComputations.PreviousQuarterIsZero = 0
				)
			THEN FIHComputations.QuarterlyChangeInTotalCostLocal
		ELSE 0
		END AS TotalFollowOnInvestmentsLocal
	,ProceedsStatus.[Status]
	,ProceedsStatus.SubStatus
	,CASE 
		WHEN FIHComputations.QuarterlyChangeInGrossValueLocal > 0
			THEN 1
		ELSE 0
		END AS IsWriteUp
	,CASE
		WHEN FIHComputations.QuarterlyChangeInGrossValueLocal < 0
			THEN 1
		ELSE 0
		END AS IsWriteDown
	,FIHComputations.QuarterlyChangeInGrossValueLocal
	,(fih.MarketValueLocal + fih.TotalProceedsLocal - fih.TotalCostLocal) AS GrossValueLocal
	,pfih.MarketValueLocal AS PreviousMarketValueLocal
	,pfih.TotalProceedsLocal AS PreviousTotalProceedsLocal
	,dbo.fnChangeInGrossValue(fih.MarketValueLocal, pfih.MarketValueLocal, CASE FIHComputations.IsNewInvestmentForQuarter
			WHEN 1
				THEN fih.TotalCostLocal
			ELSE 0
			END, CASE 
			WHEN FIHComputations.IsNewInvestmentForQuarter = 0
				AND FIHComputations.QuarterlyChangeInTotalCostLocal > 10
				THEN FIHComputations.QuarterlyChangeInTotalCostLocal
			ELSE 0
			END, fih.TotalProceedsLocal, pfih.TotalProceedsLocal) AS ChangeInGrossValueLocal
	,FIHComputations.QuarterlyChangeInTotalCostLocal
	,FIHComputations.IsNewInvestmentForQuarter
	,CASE 
		WHEN FIHComputations.IsNewInvestmentForQuarter = 0
			AND FIHComputations.QuarterlyChangeInTotalCostLocal > 10
			THEN 1
		ELSE 0
		END AS IsFollowOnInvestmentForQuarter
	,CASE fih.TotalCostLocal
		WHEN 0
			THEN 0
		ELSE (fih.MarketValueLocal + fih.TotalProceedsLocal) / fih.TotalCostLocal
		END AS GrossMultiple
	,CASE fih.RemainingCostLocal
		WHEN 0
			THEN 0
		ELSE (fih.MarketValueLocal + fih.TotalProceedsLocal) / fih.RemainingCostLocal
		END AS RemainingCostMultiple
	,CASE 
		WHEN fih.MarketValueLocal = 0
			AND FIHComputations.ChangeInTotalProceedsLocal > 0
			THEN 'Full Realization'
		WHEN FIHComputations.IsNewInvestmentForQuarter = 0
			AND FIHComputations.QuarterlyChangeInTotalCostLocal > 10
			THEN 'Follow-On'
		WHEN fih.MarketValueLocal <> 0
			AND FIHComputations.ChangeInTotalProceedsLocal > 0
			THEN 'Partial Realization'
		WHEN FIHComputations.QuarterlyChangeInGrossValueLocal > 0
			AND FIHComputations.ChangeInTotalProceedsLocal = 0
			THEN 'Write Up'
		WHEN FIHComputations.QuarterlyChangeInGrossValueLocal < 0
			AND FIHComputations.ChangeInTotalProceedsLocal = 0
			THEN 'Write Down'
		ELSE 'No Change'
		END AS [InvestmentEvent]
	,CASE 
		WHEN fih.TotalProceedsLocal = 0
			THEN 'U'
		WHEN fih.MarketValueLocal = 0
			THEN 'R'
		WHEN fih.MarketValueLocal <> 0
			THEN 'PR'
		ELSE 'X'
		END AS ShortStatus
	,FIHComputations.CurrentQuarterIsZero
FROM {{ref('GPFundInvestment')}} AS fi
INNER JOIN {{ref('stg_GPFundInvestment_History')}} AS fih ON fih.GPFundInvestmentId = fi.GPFundInvestmentId
INNER JOIN {{ref('GPFund')}} AS f ON f.GPFundId = fi.GPFundId
INNER JOIN {{ref('Entity')}} e ON e.EntityID = fi.EntityId
INNER JOIN {{ref('Period')}} p ON p.PeriodId = fih.PeriodId
LEFT JOIN {{ref('stg_GPFundInvestment_History')}} pfih ON fih.GpFundInvestmentId = pfih.GpFundInvestmentId
	AND fih.periodid - 1 = pfih.periodid
CROSS APPLY (
	SELECT CASE 
			-- There is no previous quarter data, so we treat the asofdate to be the investment date, and therefore this is a new inv
			WHEN pfih.GPFundInvestmentId IS NULL
				AND fi.InvestmentDate <= p.AsOfDate
				THEN 1
			ELSE dbo.fnSameQuarterYear(fi.InvestmentDate, p.AsOfDate)
			END AS IsNewInvestmentForQuarter
		,fih.TotalCostLocal - IsNull(pfih.TotalCostLocal, 0) AS QuarterlyChangeInTotalCostLocal
		,((fih.MarketValueLocal + fih.TotalProceedsLocal) - fih.TotalCostLocal) - ((pfih.MarketValueLocal + pfih.TotalProceedsLocal) - pfih.TotalCostLocal) AS QuarterlyChangeInGrossValueLocal
		,fih.TotalProceedsLocal - ISNULL(pfih.TotalProceedsLocal, 0) AS ChangeInTotalProceedsLocal
		,CASE 
			WHEN fih.MarketValueLocal = 0
				AND fih.TotalProceedsLocal = 0
				AND fih.TotalCostLocal = 0
				AND fih.RemainingCostLocal = 0
				THEN 1
			ELSE 0
			END AS CurrentQuarterIsZero
		,CASE 
			WHEN IsNull(pfih.MarketValueLocal, 0) = 0
				AND IsNull(pfih.TotalProceedsLocal, 0) = 0
				AND IsNull(pfih.TotalCostLocal, 0) = 0
				AND IsNull(pfih.RemainingCostLocal, 0) = 0
				THEN 1
			ELSE 0
			END AS PreviousQuarterIsZero
	) AS FIHComputations
CROSS APPLY (
	SELECT [Status]
		,IsNull([Substatus], '') AS [Substatus]
	FROM [dbo].[fnProceedsStatus](fih.TotalProceedsLocal, fih.TotalCostLocal, fih.RemainingCostLocal, fih.MarketValueLocal, 0.01, fih.Status)
	) AS ProceedsStatus
WHERE e.IsInvestable = 1
	AND fi.IsNetOtherAssets = 0
	AND fi.InvestmentDate <= p.AsOfDate