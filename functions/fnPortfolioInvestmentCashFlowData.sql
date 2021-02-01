USE [PRIVATE_MARKETS]
GO

/****** Object:  UserDefinedFunction [dbo].[fnPortfolioInvestmentCashFlowData]    Script Date: 1/31/2021 1:41:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[fnPortfolioInvestmentCashFlowData] (
	@portfolioInvestmentId VARBINARY(8000)
	,@asOfDate DATE
	)
RETURNS @cashFlowData TABLE (
	AsOfDate DATE NOT NULL
	,TotalDistributionsLocal MONEY NOT NULL
	,TotalDistributionsClient MONEY NOT NULL
	,TotalFundingLocal MONEY NOT NULL
	,TotalFundingClient MONEY NOT NULL
	,TotalAmountRecallableLocal MONEY NOT NULL
	,TotalAmountRecallableClient MONEY NOT NULL
	,ValuationsLocal MONEY NOT NULL
	,ValuationsClient MONEY NOT NULL
	,MinFundingDate DATE NULL
	)
AS
BEGIN
	IF (@asOfDate IS NULL)
		RETURN

	-- Get Total Distributions, Funding & NAV
	INSERT @cashFlowData
	SELECT @asOfDate
		,IsNull(Sum(IsNull(cf.CashDistributionsLocal, 0) + IsNull(cf.StockDistributionsLocal, 0)), 0) AS TotalDistributionsLocal
		,IsNull(Sum(IsNull(cf.CashDistributionsClient, 0) + IsNull(cf.StockDistributionsClient, 0)), 0) AS TotalDistributionsClient
		,IsNull(Sum(IsNull(cf.FundingLocal, 0) + IsNull(cf.AdditionalFeesLocal, 0)), 0) AS TotalFundingLocal
		,IsNull(Sum(IsNull(cf.FundingClient, 0) + IsNull(cf.AdditionalFeesClient, 0)), 0) AS TotalFundingClient
		,IsNull(Sum(IsNull(cf.AmountRecallableLocal, 0)), 0) AS TotalAmountRecallableLocal
		,IsNull(Sum(IsNull(cf.AmountRecallableClient, 0)), 0) AS TotalAmountRecallableClient
		,IsNull(SUM([ReportedValuationLocal]), 0) AS ValuationsLocal
		,IsNull(SUM([ReportedValuationClient]), 0) AS ValuationsClient
		,Min(CASE 
				WHEN IsNull(cf.FundingLocal, 0) = 0
					THEN NULL
				ELSE cf.CashFlowDate
				END) AS MinFundingDate
	FROM [dbo].[PortfolioInvestment_CashFlows] AS cf
	CROSS APPLY (
		SELECT [ReportedValuationLocal]
			,[ReportedValuationClient]
		FROM [dbo].[PortfolioInvestment_Valuations] piv
		WHERE @asofdate = [ValuationDate]
			AND piv.PortfolioInvestmentId = @portfolioInvestmentId
		) AS NAV
	WHERE cf.PortfolioInvestmentId = @portfolioInvestmentId
		AND cf.CashFlowDate <= @asOfDate
		AND cf.Exclude = 0

	RETURN
END
