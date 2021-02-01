SELECT pih.AsOfDate
	,pih.PortfolioInvestmentID
	,PIXirr.XirrClient
	,PIXirr.XirrLocal
FROM [dbo].[PortfolioInvestment_HistoryByQuarter] AS pih
INNER JOIN dbo.PortfolioInvestment poi ON poi.PortfolioInvestmentID = pih.PortfolioInvestmentID
INNER JOIN dbo.Portfolio p ON p.PortfolioID = poi.PortfolioID
INNER JOIN dbo.GPFund gpf ON gpf.GPFundID = poi.GPFundID
CROSS APPLY (
	SELECT ffiv.ValuationDate AS LatestValuationDate
	FROM [dbo].[PortfolioInvestment_Valuations] AS ffiv
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