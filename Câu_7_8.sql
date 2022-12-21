USE [BikeStores]
GO

-- Câu 7: Từ câu 1 và 2 trong bài tập buổi 5, các bạn gộp truy vấn của cả hai câu lại thành một truy vấn và thêm 4 cột: 
--		quarter, QTD,  rolling_3_months_in_same_year, rolling_6_months_in_same_year. 
--		Sau đó lưu truy vấn lại thành 1 view

CREATE VIEW [dbo].[sales_summary]
AS
WITH _TEMP
AS
(
	SELECT 
		YEAR([order_date]) AS [year]
		,DATEPART(QUARTER, [order_date]) AS [quarter]
		,MONTH([order_date]) AS [month]
		,SUM([quantity] * [list_price] * (1 - [discount])) AS [total_net_sale]
	FROM [sales].[orders] o
	JOIN [sales].[order_items] oi
		ON o.[order_id] = oi.[order_id]
	GROUP BY
		YEAR([order_date])
		,DATEPART(QUARTER, [order_date])
		,MONTH([order_date])
)
SELECT
	[year]
	,'Q' + CAST([quarter] AS CHAR(2)) AS [quarter]
	,[month]
	,[total_net_sale]
	,SUM([total_net_sale]) OVER (PARTITION BY [year] ORDER BY [month]) AS [MTD]
	,SUM([total_net_sale]) OVER (PARTITION BY [year] ORDER BY [quarter]) AS [QTD]
	,SUM([total_net_sale]) OVER (PARTITION BY [year] ORDER BY [year]) AS [YTD]
	,SUM([total_net_sale]) OVER (PARTITION BY [year] ORDER BY [month] ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS [rolling_3_months_in_same_year]
	,SUM([total_net_sale]) OVER (PARTITION BY [year] ORDER BY [month] ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS [rolling_6_months_in_same_year]
	,LAG([total_net_sale]) OVER (ORDER BY [year], [month]) [last_month]
	,[total_net_sale] - LAG([total_net_sale]) OVER (ORDER BY [year], [month]) AS [diff_between_months]
	,LAG([total_net_sale]) OVER (PARTITION BY [month] ORDER BY [year]) [same_period_last_year]
	,[total_net_sale] - LAG([total_net_sale]) OVER (PARTITION BY [month] ORDER BY [year]) AS [diff_between_same_period_last_year]
FROM _TEMP
--ORDER BY [year], [month]
GO

-- Câu 8:
 --DROP TABLE [sales].[date]

CREATE TABLE [sales].[date]
(   --[Datekey] [int] PRIMARY KEY ,
	[Date] [date] PRIMARY KEY,
	[Year] [smallint] NOT NULL,
	[Quarter] [tinyint] NOT NULL,
	[Month] [tinyint] NOT NULL,
	[MonthName] [varchar](20) NOT NULL,
	[MonthShortName] [char](3) NOT NULL,
	[WeekDay] [tinyint] NOT NULL,
	[WeekDayName] [varchar](20) NOT NULL,
	[WeekDayShortName] [char](3) NOT NULL,
	[WeekOfYear] [tinyint] NOT NULL,
	[DayOfYear] [smallint] NOT NULL,
	[Day] [tinyint] NOT NULL,
	[FirstDateofMonth] [date] NOT NULL,
	[LastDateofMonth] [date] NOT NULL,
	[FirstDateofWeek] [date] NOT NULL,
	[LastDateofWeek] [date] NOT NULL
)
GO

CREATE PROCEDURE [dbo].[sp_PopulateDataForDateTable]
	@FromDate date
	,@ToDate date
AS
BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE [sales].[date]

	WHILE @FromDate <= @ToDate
	BEGIN
		INSERT INTO [sales].[date]
		SELECT 
		--[Datekey] = year( @FromDate) * 1000 + month( @FromDate) * 100 + day(@FromDate)
		[Date] = @FromDate
			,[Year] = YEAR(@FromDate)
			,[Quarter] = DATEPART(QUARTER, @FromDate)
			,[Month] = MONTH(@FromDate)
			,[MonthName] = DATENAME(MONTH, @FromDate)
			,[MonthShortName] = LEFT(DATENAME(MONTH, @FromDate), 3)
			,[WeekDay] = DATEPART(WEEKDAY, @FromDate)
			,[WeekDayName] = DATENAME(WEEKDAY, @FromDate)
			,[WeekDayShortName] = LEFT(DATENAME(WEEKDAY, @FromDate), 3)
			,[WeekOfYear] = DATEPART(WEEK, @FromDate)
			,[DayOfYear] = DATEPART(DAYOFYEAR, @FromDate)
			,[Day] = DAY(@FromDate)
			,[FirstDateofMonth] = DATEFROMPARTS(YEAR(@FromDate), MONTH(@FromDate), 1)
			,[LastDateofMonth] = EOMONTH(@FromDate)
			,[FirstDateofWeek] = DATEADD(DAY, -1 * DATEPART(WEEKDAY, @FromDate) + 1, @FromDate)
			,[LastDateofWeek] = DATEADD(DAY, (7 - DATEPART(WEEKDAY, @FromDate)), @FromDate)

		SET @FromDate = DATEADD(DAY, 1, @FromDate)
	END
END

--Drop PROCEDURE [dbo].[sp_PopulateDataForDateTable];

EXEC [dbo].[sp_PopulateDataForDateTable] @FromDate = '2016-01-01', @ToDate = '2018-12-31'
 
 
---sql server analysis services (powerbi) --- đó là lý do viết đk dax 
---tablular model 
---cube 
-- => để tối ưu hóa 
-- ôn lại sql1 , qtam về select , insert ,update,deleted (lý thuyết) , cte,subquery,tempory table (phân biệt 3 cái)
--windowfunction, duplication, view, hàm, join,upivot/pivot(coi thêm)
---cross apply
