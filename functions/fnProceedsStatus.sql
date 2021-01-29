USE [PRIVATE_MARKETS]
GO

/****** Object:  UserDefinedFunction [dbo].[fnProceedsStatus]    Script Date: 1/25/2021 4:36:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Martin Supple
-- Create date: 12/05/2011
-- Description:	Calculate Status / Sub-Status of a GP FundInvestment
-- 04/06/2012 - msupple
-- Now taking investment status into consideration
-- =============================================
ALTER FUNCTION [Flag].[fnProceedsStatus] (
	@totalProceeds MONEY
	,@totalCost MONEY
	,@remainingCost MONEY
	,@marketValue MONEY
	,@proceedsThresholdPctg DECIMAL = 0.01
	,@investmentStatus VARCHAR(100)
	)
RETURNS @result TABLE (
	[Status] VARCHAR(50)
	,[SubStatus] VARCHAR(50)
	)
AS
BEGIN
	DECLARE @Status VARCHAR(50)
	DECLARE @SubStatus VARCHAR(50)

	IF (@marketValue <> 0)
	BEGIN
		IF (
				(@remainingCost = 0)
				AND (IsNull(@investmentStatus, '') = 'Escrow')
				)
		BEGIN
			SET @Status = 'Inactive'
			SET @SubStatus = 'Realized'
		END
		ELSE
		BEGIN
			-- Active
			SET @Status = 'Active'

			IF (@remainingCost = 0)
			BEGIN
				IF (@marketValue > 0)
				BEGIN
					SET @SubStatus = 'Above Cost'
				END
				ELSE
				BEGIN
					SET @SubStatus = 'Below Cost'
				END
			END
			ELSE
			BEGIN
				DECLARE @remValueMultiple DECIMAL(38, 9)

				SET @remValueMultiple = Convert(DECIMAL, @marketValue) / Convert(DECIMAL, @remainingCost)
				SET @SubStatus = CASE 
						WHEN (@remValueMultiple > 1)
							THEN 'Above Cost'
						WHEN (@remValueMultiple < 1)
							THEN 'Below Cost'
						ELSE 'At Cost'
						END;
			END
		END
	END
	ELSE
	BEGIN
		SET @Status = 'Inactive'

		IF (@remainingCost > 0)
			OR (
				@remainingCost < 0
				AND @totalProceeds = 0
				AND @totalCost = 0
				)
		BEGIN
			SET @SubStatus = 'Written Down to Zero'
		END
		ELSE
		BEGIN
			IF (@totalCost = 0)
				AND (
					@remainingCost = 0
					AND @totalProceeds <> 0
					AND @marketValue = 0
					)
			BEGIN
				SET @SubStatus = 'Realized'
			END
			ELSE
			BEGIN
				DECLARE @proceedsPctg DECIMAL(38, 9)

				IF (@totalCost <> 0)
					SET @proceedsPctg = Convert(DECIMAL, @totalProceeds) / Convert(DECIMAL, @totalCost)
				SET @SubStatus = CASE 
						WHEN @proceedsPctg IS NULL
							THEN 'N/A'
						WHEN @proceedsPctg > @proceedsThresholdPctg
							THEN 'Realized'
						ELSE 'Written Off'
						END
			END
		END
	END

	INSERT INTO @result
	SELECT @Status
		,@SubStatus

	RETURN
END