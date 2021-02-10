SELECT p.AsOfDate
	,p.PeriodId
	,po.PortfolioInvestmentID
	,PIvaluationData.LatestValuationDate
FROM {{ref('Period')}} p
CROSS APPLY (
	SELECT PortfolioInvestmentId
	FROM PortfolioInvestment
	) po
CROSS APPLY (
	-- valuation dates
	SELECT MAX(piv.ValuationDate) AS LatestValuationDate
	FROM {{ref('PortfolioInvestment_Valuations')}} AS piv
	WHERE piv.PortfolioInvestmentId = po.PortfolioInvestmentId
		AND piv.ValuationDate <= p.AsOfDate
	) AS PIvaluationData
WHERE PIvaluationData.LatestValuationDate IS NOT NULL