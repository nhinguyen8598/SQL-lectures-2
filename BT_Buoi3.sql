USE [WorldEvents]
GO

-- BT1
-- Cách 1
CREATE PROCEDURE [dbo].[uspInformation]
	@tableName VARCHAR(50)
AS
BEGIN
	IF @tableName = 'Event'
	BEGIN
		SELECT TOP (5) 
			[EventID]
			,[EventName]
			,[EventDetails]
			,[EventDate]
			,[CountryID]
			,[CategoryID]
		FROM [dbo].[tblEvent]
	END

	IF @tableName = 'Country'
	BEGIN
		SELECT TOP (5) 
			[CountryID]
			,[CountryName]
			,[ContinentID]
		FROM [dbo].[tblCountry]
	END

	IF @tableName = 'Continent'
	BEGIN
		SELECT TOP (5) 
			[ContinentID]
			,[ContinentName]
			,[Summary]
		FROM [dbo].[tblContinent]
	END
	
	ELSE
	BEGIN
		PRINT N'Không tìm thấy thông tin, vui lòng nhập Event, Country hoặc Continent.'
	END
END
GO

-- Cách 2
CREATE PROCEDURE [dbo].[uspInformation2]
	@tableName varchar(50)
AS
BEGIN
	DECLARE @sql NVARCHAR(100)

	IF @tableName IN ('Event', 'Country', 'Continent')
	BEGIN
		SET @sql = N'SELECT TOP (5) * FROM dbo.tbl' + @tableName

		EXEC sp_executesql @sql
	END
	ELSE
	BEGIN
		PRINT N'Không tìm thấy thông tin, vui lòng nhập Event, Country hoặc Continent.'
	END
END
GO

EXEC [dbo].[uspInformation] @tableName = 'Continent1'
EXEC [dbo].[uspInformation2] @tableName = 'Event1'

-- BT2
-- Cách 1

CREATE TABLE [dbo].[EventSummarybyCountry]
(
	[CountryId] INT, 
	[CountryName] NVARCHAR(255), 
	[Year] INT, 
	[NumberOfEvents] INT
)
GO

CREATE PROCEDURE [dbo].[uspInsertDataToEventSummarybyCountry]
AS
BEGIN
	TRUNCATE TABLE [dbo].[EventSummarybyCountry] 
	--DELETE FROM [dbo].[EventSummarybyCountry] ;

	DECLARE 
		@minYear INT
		,@maxYear INT

	SET @minYear = (SELECT MIN(YEAR([EventDate])) FROM [dbo].[tblEvent])
	SET @maxYear = (SELECT MAX(YEAR([EventDate])) FROM [dbo].[tblEvent])

	WHILE @minYear <= @maxYear
	BEGIN
	
		INSERT INTO [dbo].[EventSummarybyCountry] 
		(
			[CountryId]
			,[CountryName]
			,[Year]
			,[NumberOfEvents]
		)
		SELECT 
			c.[CountryID]
			,[CountryName]
			,YEAR(e.[EventDate]) AS [Year] 
			,COUNT(*) AS [NumberOfEvents]
		FROM [dbo].[tblCountry] c
		LEFT JOIN [dbo].[tblEvent] e
			ON c.[CountryID] = e.[CountryID]
		WHERE YEAR(e.[EventDate]) = @minYear
		GROUP BY 
			c.[CountryID]
			,[CountryName]
			,YEAR(e.[EventDate])

		--PRINT @@ROWCOUNT

		IF @@ROWCOUNT > 0
		BEGIN
			INSERT INTO [dbo].[EventSummarybyCountry]
			SELECT 
				c.[CountryID]
				,c.[CountryName]
				,@minYear AS [Year] 
				,0 AS [NumberOfEvents]
			FROM [dbo].[tblCountry] c
			LEFT JOIN [dbo].[EventSummarybyCountry] e
				ON c.[CountryID] = e.[CountryId]
				AND e.[Year] = @minYear
			WHERE e.[CountryId] IS NULL
		END
		ELSE
		BEGIN
			INSERT INTO [dbo].[EventSummarybyCountry]
			SELECT 
				c.[CountryID]
				,c.[CountryName]
				,@minYear AS [Year] 
				,0 AS [NumberOfEvents]
			FROM [dbo].[tblCountry] c
		END
    
		SET @minYear = @minYear + 1
	END
END
GO

-- Cách 2

ALTER PROCEDURE [dbo].[uspInsertDataToEventSummarybyCountry2]
AS
BEGIN
	TRUNCATE TABLE [dbo].[EventSummarybyCountry]

	DECLARE 
		@minYear INT
		,@maxYear INT

	SET @minYear = (SELECT MIN(YEAR([EventDate])) FROM [dbo].[tblEvent])
	SET @maxYear = (SELECT MAX(YEAR([EventDate])) FROM [dbo].[tblEvent])

	WHILE @minYear <= @maxYear
	BEGIN

		INSERT INTO [dbo].[EventSummarybyCountry]
		SELECT 
			[CountryID]
			,[CountryName]
			,@minYear AS [Year]
			,0 AS [NumberOfEvents]
		FROM [dbo].[tblCountry]
	
		
		;WITH _TEMP
		AS
		(
			SELECT 
				c.[CountryID]
				,[CountryName]
				,YEAR(e.[EventDate]) AS [Year] 
				,COUNT(*) AS [NumberOfEvents]
			FROM [dbo].[tblCountry] c
			LEFT JOIN [dbo].[tblEvent] e
				ON c.[CountryID] = e.[CountryID]
			WHERE YEAR(e.[EventDate]) = @minYear
			GROUP BY 
				c.[CountryID]
				,[CountryName]
				,YEAR(e.[EventDate])
		)
		UPDATE es
		SET es.[Year] = t.[Year]
			,es.[NumberOfEvents] = t.[NumberOfEvents]
		FROM [dbo].[EventSummarybyCountry] es
		JOIN _TEMP t
			ON es.[CountryId] = t.[CountryID]
			AND es.[Year] = t.[Year]

		SET @minYear = @minYear + 1
	END
END
GO

-- EXEC [dbo].[uspInsertDataToEventSummarybyCountry]
-- EXEC [dbo].[uspInsertDataToEventSummarybyCountry2]

-- BT3
CREATE FUNCTION [dbo].[udf_ContinentSummary]
(
	@continent VARCHAR(50),
	@month VARCHAR(10)
)
RETURNS TABLE
AS
RETURN
	SELECT
		cn.[ContinentName]
		,COUNT(DISTINCT(e.[EventID])) AS [Number of events]
		,COUNT(DISTINCT(e.[CountryID])) AS [Number of countries]
		,COUNT(DISTINCT(e.[CategoryID])) AS [Number of categories]
	FROM [dbo].[tblEvent] e
	INNER JOIN [dbo].[tblCountry] c 
		ON e.[CountryID] = c.[CountryID]
	INNER JOIN [dbo].[tblContinent] cn 
		ON c.[ContinentID] = cn.[ContinentID]
	WHERE cn.[ContinentName] = @Continent 
		AND FORMAT(e.[EventDate], 'MMMM') = @Month
	GROUP BY cn.[ContinentName]
GO

-- SELECT * FROM [dbo].[udf_ContinentSummary]('Europe','April')

-- BT4
ALTER PROCEDURE [dbo].[spSelect]
(
	@Columns VARCHAR(100),
	@TableName VARCHAR(50),
	@NumberRows	INT = NULL,
	@OrderColumn VARCHAR(50) = NULL
)
AS
BEGIN
	DECLARE @SqlString NVARCHAR(1000)

	IF (@NumberRows IS NULL AND @OrderColumn IS NULL)
	BEGIN
		SET @SqlString = N'SELECT ' + @Columns + ' FROM ' + @TableName
		
		EXEC sp_executesql @SqlString
	END

	IF (@NumberRows IS NULL AND @OrderColumn IS NOT NULL)
	BEGIN
		SET @SqlString = 
			N'SELECT' + @Columns + 
			' FROM ' + @TableName + 
			' ORDER BY ' + @OrderColumn
	
		EXEC sp_executesql @SqlString
	END

	IF (@NumberRows IS NOT NULL AND @OrderColumn IS NULL)
	BEGIN
		SET @SqlString = 
			N'SELECT TOP ' + CAST(@NumberRows AS VARCHAR(5)) + 
			' ' + @Columns + 
			' FROM ' + @TableName
	
		EXEC sp_executesql @SqlString
	END

	ELSE
	BEGIN
		SET @SqlString = 
			N'SELECT TOP ' + CAST(@NumberRows AS VARCHAR(5)) + 
			' ' + @Columns + 
			' FROM ' + @TableName + 
			' ORDER BY ' + @OrderColumn
	
		EXEC sp_executesql @SqlString
	END
END
GO

EXEC [dbo].[spSelect]
	@Columns = '[EventName],[EventDetails],[EventDate]'
	,@TableName = '[dbo].[tblEvent]'

EXEC [dbo].[spSelect]
	@Columns = '[EventName],[EventDetails],[EventDate]'
	,@TableName = '[dbo].[tblEvent]'
	,@NumberRows = 5

EXEC [dbo].[spSelect]
	@Columns = '[EventName],[EventDetails],[EventDate]'
	,@TableName = '[dbo].[tblEvent]'
	,@OrderColumn = '[EventDetails] DESC'

EXEC [dbo].[spSelect]
	@Columns = '[EventName],[EventDetails],[EventDate]'
	,@TableName = '[dbo].[tblEvent]'
	,@NumberRows = 10
	,@OrderColumn = '[EventDetails] ASC'