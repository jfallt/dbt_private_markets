USE [PRIVATE_MARKETS]
GO
/****** Object:  UserDefinedFunction [dbo].[fnSameQuarterYear]    Script Date: 1/25/2021 4:19:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jared Fallt
-- Create date: 1/25/2020
-- Description:	Determines if 2 dates are in the same quarter
-- =============================================
CREATE FUNCTION [dbo].[fnSameQuarterYear]
(
@date1 DateTime,
@date2 DateTime
)
RETURNS bit
AS
BEGIN
	DECLARE @result bit

	If ((DatePart(quarter, @date1) = DatePart(quarter, @date2)) And
        (DatePart(year, @date1) = DatePart(year, @date2)))
        Set @result = 1
    Else
		Set @result = 0
	RETURN @result
END