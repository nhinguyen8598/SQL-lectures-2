-- BT1
-- Viết truy vấn thống kê thông tin bán hàng theo mẫu sau: year, month, order_date, net_sale, MTD (month-to-date), YTD (year-to-date)
WITH _TEMP
AS
(
	SELECT 
		YEAR([order_date]) AS [year]
		,DATEPART(QUARTER, [order_date]) AS [quarter]
		,MONTH([order_date]) AS [month]
		,[order_date]
		,[quantity] * [list_price] * (1- [discount]) AS [net_sale]
	FROM [BikeStores].[sales].[orders] o
	JOIN [sales].[order_items] oi
		ON o.[order_id] = oi.order_id
)
SELECT
	[year]
	,[month]
	,[order_date]
	,[net_sale]
	,SUM([net_sale]) OVER (PARTITION BY [year], [quarter] ORDER BY [order_date]) AS [QTD]
	,SUM([net_sale]) OVER (PARTITION BY [year], [month] ORDER BY [order_date]) AS [MTD]
	,SUM([net_sale]) OVER (PARTITION BY [year] ORDER BY [order_date]) AS [YTD]
FROM _TEMP


-- BT2
-- Viết truy vấn thống kê thông tin bán hàng theo mẫu sau: 
--	year, month, total_net_sale (TNS)
--		,last_month_TNS, diff_months (total_net_sale - last_month_TNS)
--		,same_period_last_year_TNS, diff_between_same_period_last_year_TNS (total_net_sale - same_period_last_year_TNS)
;WITH _TEMP
AS
(
	SELECT 
		YEAR([order_date]) AS [year]
		,MONTH([order_date]) AS [month]
		,SUM([quantity] * [list_price] * (1- [discount])) AS [total_net_sale]
	FROM [BikeStores].[sales].[orders] o
	JOIN [sales].[order_items] oi
		ON o.[order_id] = oi.order_id
	GROUP BY YEAR([order_date])
		,MONTH([order_date])
)
SELECT
	[year]
	,[month]
	,[total_net_sale]
	,LAG([total_net_sale]) OVER (ORDER BY [year], [month]) [last_month]
	--,LAG([total_net_sale]) OVER (PARTITION BY [year] ORDER BY [month]) [last_month]
	,[total_net_sale] - LAG([total_net_sale]) OVER (PARTITION BY [year] ORDER BY [month]) AS [diff_between_months]
	,LAG([total_net_sale]) OVER (PARTITION BY [month] ORDER BY [year]) [same_period_last_year]
	,[total_net_sale] - LAG([total_net_sale]) OVER (PARTITION BY [month] ORDER BY [year]) AS [diff_between_same_period_last_year]
FROM _TEMP
ORDER BY [year], [month]

-- BT3: Từ truy vấn ở bài tập 1 và bài tập 2, tạo 2 view cho các truy vấn này.
CREATE VIEW [dbo].[vw_sales_summary]
AS
WITH _TEMP
AS
(
	SELECT 
		YEAR([order_date]) AS [year]
		,MONTH([order_date]) AS [month]
		,[order_date]
		,[quantity] * [list_price] * (1- [discount]) AS [net_sale]
	FROM [BikeStores].[sales].[orders] o
	JOIN [sales].[order_items] oi
		ON o.[order_id] = oi.order_id
)
SELECT
	[year]
	,[month]
	,[order_date]
	,[net_sale]
	,SUM([net_sale]) OVER (PARTITION BY [year], [month] ORDER BY [order_date]) AS [MTD]
	,SUM([net_sale]) OVER (PARTITION BY [year] ORDER BY [order_date]) AS [YTD]
FROM _TEMP
GO

CREATE VIEW [dbo].[vw_sales_summary2]
AS
WITH _TEMP
AS
(
	SELECT 
		YEAR([order_date]) AS [year]
		,MONTH([order_date]) AS [month]
		,SUM([quantity] * [list_price] * (1- [discount])) AS [total_net_sale]
	FROM [BikeStores].[sales].[orders] o
	JOIN [sales].[order_items] oi
		ON o.[order_id] = oi.order_id
	GROUP BY YEAR([order_date])
		,MONTH([order_date])
)
SELECT
	[year]
	,[month]
	,[total_net_sale]
	--,LAG([total_net_sale]) OVER (PARTITION BY [year] ORDER BY [month]) [last_month]
	,LAG([total_net_sale]) OVER (ORDER BY [month]) [last_month]
	,[total_net_sale] - LAG([total_net_sale]) OVER (PARTITION BY [year] ORDER BY [month]) AS [diff_between_months]
	,LAG([total_net_sale]) OVER (PARTITION BY [month] ORDER BY [year]) [same_period_last_year]
	,[total_net_sale] - LAG([total_net_sale]) OVER (PARTITION BY [month] ORDER BY [year]) AS [diff_between_same_period_last_year]
FROM _TEMP
--ORDER BY [year], [month]
GO

-- BT4: Tạo 1 view trả về 3 sản phẩm có net_value cao nhất của mỗi đơn hàng,  
--		sau đó tạo thêm 1 view để thống kê tần suất xuất hiện của các sản phẩm đó.
CREATE VIEW [dbo].[vw_top3_netsale]
AS
WITH _TEMP
AS
(
	SELECT
		[order_id]
		,[product_name]
		,[quantity] * oi.[list_price] * (1 - [discount]) AS [net_sale]
	FROM [sales].[order_items] oi
	LEFT JOIN [production].[products] p
		ON oi.[product_id] = p.[product_id]
)
,_RANKING
AS
(
	SELECT
		[order_id]
		,[product_name]
		,[net_sale]
		,ROW_NUMBER() OVER (PARTITION BY [order_id] ORDER BY [net_sale] DESC) AS [ranking]
	FROM _TEMP
)
SELECT
	[order_id]
	,[product_name]
	,[net_sale]
FROM _RANKING
WHERE [ranking] <= 3
GO

select 
*
from  [dbo].[vw_top3_netsale]

 --DROP   VIEW [dbo].[vw_top3_netsale];

CREATE VIEW [dbo].[vw_productSales_frequency]
AS
SELECT
	[product_name]
	,COUNT(*) AS [frequency]
FROM [dbo].[vw_top3_netsale]
GROUP BY [product_name]
--ORDER BY [frequency] DESC
GO
--drop VIEW [dbo].[vw_productSales_frequency]

-- BT5: Chạy đoạn lệnh dưới đây, sau đó viết truy vấn để xóa đi những dòng trùng lặp trong bảng vừa tạo từ đoạn lệnh này.

DROP TABLE IF EXISTS [sales].[contacts]
GO

CREATE TABLE [sales].[contacts](
    [contact_id] INT IDENTITY(1,1) PRIMARY KEY,
    [first_name] NVARCHAR(100) NOT NULL,
    [last_name] NVARCHAR(100) NOT NULL,
    [email] NVARCHAR(255) NOT NULL,
)
GO

INSERT INTO [sales].[contacts]
    ([first_name],[last_name],[email]) 
VALUES
    ('Syed','Abbas','syed.abbas@example.com'),
    ('Catherine','Abel','catherine.abel@example.com'),
    ('Kim','Abercrombie','kim.abercrombie@example.com'),
    ('Kim','Abercrombie','kim.abercrombie@example.com'),
    ('Kim','Abercrombie','kim.abercrombie@example.com'),
    ('Hazem','Abolrous','hazem.abolrous@example.com'),
    ('Hazem','Abolrous','hazem.abolrous@example.com'),
    ('Humberto','Acevedo','humberto.acevedo@example.com'),
    ('Humberto','Acevedo','humberto.acevedo@example.com'),
    ('Pilar','Ackerman','pilar.ackerman@example.com')
GO

SELECT 
   [contact_id]
   ,[first_name]
   ,[last_name]
   ,[email]
FROM [sales].[contacts]

;WITH cte 
AS 
(
	SELECT 
		[contact_id]
		,[first_name]
		,[last_name]
		,[email]
		,ROW_NUMBER() OVER (PARTITION BY [first_name], [last_name], [email]
							ORDER BY [first_name], [last_name], [email]) [row_num]
	FROM [sales].[contacts]
)
DELETE FROM cte
WHERE [row_num] > 1