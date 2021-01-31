USE [PRIVATE_MARKETS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jared Fallt
-- Create date: 01/25/2021
-- Description:	Change In Gross Value Client Period over Period (quarter or year for example)
-- =============================================
ALTER FUNCTION [dbo].[fnChangeInGrossValue]
(
@currentMarketValue money,
@previousMarketValue money,
@currentNewInvestments money,
@currentFollowOnInvestments money,
@currentProceeds money,
@previousProceeds money
)
RETURNS money
AS
BEGIN
	DECLARE @changeInGrossValueClient money
	
	Select @changeInGrossValueClient = 
	     IsNull(@currentMarketValue, 0) - IsNull(@previousMarketValue, 0) -
			IsNull(@currentNewInvestments, 0) - IsNull(@currentFollowOnInvestments, 0) +
			(IsNull(@currentProceeds, 0) - IsNull(@previousProceeds, 0));
	RETURN @changeInGrossValueClient
END