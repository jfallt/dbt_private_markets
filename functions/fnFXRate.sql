USE [PRIVATE_MARKETS]
GO

/****** Object:  UserDefinedFunction [PRIVATE_MARKETS].[fnFXRate]    Script Date: 1/25/2021 5:04:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Martin Supple
-- Create date: 11/10/2011
-- Description:	Get Fx Rate for a given from/to currency code and as of date
-- 08/14/2012 - msupple
-- Increased precision to decimal(22,19)
-- 08/22/2013 - msupple
-- Increased size to 26,19 (squadron) for korean currency
-- =============================================
ALTER FUNCTION [dbo].[fnFXRate] (
	@currencyCodeFrom CHAR(3)
	,@currencyCodeTo CHAR(3)
	,@rateAsOfDate DATE
	)
RETURNS DECIMAL(26, 19)
AS
BEGIN
	DECLARE @rate DECIMAL(26, 19)

	IF (@currencyCodeFrom = @currencyCodeTo)
		SELECT @rate = 1
	ELSE
		SELECT @rate = cr.Rate
		FROM dbo.Currency AS cr
		WHERE (
				(cr.CurrencyCodeFrom = @currencyCodeFrom)
				AND (cr.CurrencyCodeTo = @currencyCodeTo)
				AND (cr.RateAsOfDate = @rateAsOfDate)
				)

	RETURN @rate
END
