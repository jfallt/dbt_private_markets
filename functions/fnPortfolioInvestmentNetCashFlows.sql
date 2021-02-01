USE [PRIVATE_MARKETS]
GO

/****** Object:  UserDefinedFunction [dbo].[fnPortfolioInvestmentNetCashFlows]    Script Date: 1/31/2021 2:34:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Martin Supple
-- Create date: 10/28/2011
-- Description:	Return net cash flows with nav for a given portfolio and as of date
--
-- Change History
-- 12/10/2012 - msupple
-- Removed amount recallable from net cash flow computation, since Burgiss already takes this into account
-- This was discovered during QIP2 project
-- 07/17/2014 - msupple
-- Union vs Union All was removing duplicate cash flows from first (top) part of union..
-- =============================================
CREATE FUNCTION [dbo].[fnPortfolioInvestmentNetCashFlows] (
	@portfolioInvestmentId VARBINARY(8000)
	,@asOfDate DATE
	,@valuationLocal MONEY
	,@valuationClient MONEY
	)
RETURNS @cashFlowData TABLE (
	CashFlowDate DATE NOT NULL
	,CashFlowAmountClient MONEY NOT NULL
	,CashFlowAmountLocal MONEY NOT NULL PRIMARY KEY (CashFlowDate)
	)
AS
BEGIN
	IF @asOfDate IS NULL
		RETURN

	-- Assemble cash flow data using NAV from above
	INSERT INTO @cashFlowData (
		CashFlowDate
		,CashFlowAmountClient
		,CashFlowAmountLocal
		)
	SELECT cfs.CashFlowDate
		,Sum(TotalCashFlowClient)
		,Sum(TotalCashFlowLocal)
	FROM (
		SELECT cf.CashFlowDate AS CashFlowDate
			,
			--IsNull(cf.AmountRecallableLocal, 0) +
			IsNull(cf.FundingLocal, 0) + IsNull(cf.AdditionalFeesLocal, 0) + IsNull(cf.CashDistributionsLocal, 0) + IsNull(cf.StockDistributionsLocal, 0) AS TotalCashFlowLocal
			,
			--IsNull(cf.AmountRecallableClient, 0) +
			IsNull(cf.FundingClient, 0) + IsNull(cf.AdditionalFeesClient, 0) + IsNull(cf.CashDistributionsClient, 0) + IsNull(cf.StockDistributionsClient, 0) AS TotalCashFlowClient
		FROM [dbo].[PortfolioInvestment_CashFlows] AS cf
		WHERE cf.PortfolioInvestmentId = @portfolioInvestmentId
			AND cf.CashFlowDate <= @asOfDate
			AND cf.Exclude = 0
		
		UNION ALL
		
		SELECT @asOfDate AS CashFlowDate
			,@valuationLocal AS TotalCashFlowLocal
			,@valuationClient AS TotalCashFlowClient
		WHERE @valuationLocal IS NOT NULL
			AND @valuationClient IS NOT NULL
		) AS cfs
	GROUP BY cfs.CashFlowDate

	RETURN
END
