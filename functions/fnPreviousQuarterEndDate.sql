USE [PRIVATE_MARKETS]
GO

/****** Object:  UserDefinedFunction [dbo].[fnPreviousQuarterEndDate]    Script Date: 2/1/2021 3:48:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Martin Supple
-- Create date: 11/22/2011
-- Description:	Get previous quarter end date
-- =============================================
ALTER FUNCTION [dbo].[fnPreviousQuarterEndDate] (@fromQuarterEndDate DATE)
RETURNS DATE
AS
BEGIN
	DECLARE @previousQuarterEndDate DATE

	IF (DatePart(quarter, @fromQuarterEndDate) = 1)
		SELECT @previousQuarterEndDate = '12/31/' + convert(VARCHAR, year(@fromQuarterEndDate) - 1)

	IF (DatePart(quarter, @fromQuarterEndDate) = 2)
		SELECT @previousQuarterEndDate = '03/31/' + convert(VARCHAR, year(@fromQuarterEndDate))

	IF (DatePart(quarter, @fromQuarterEndDate) = 3)
		SELECT @previousQuarterEndDate = '06/30/' + convert(VARCHAR, year(@fromQuarterEndDate))

	IF (DatePart(quarter, @fromQuarterEndDate) = 4)
		SELECT @previousQuarterEndDate = '09/30/' + convert(VARCHAR, year(@fromQuarterEndDate))

	RETURN @previousQuarterEndDate
END
