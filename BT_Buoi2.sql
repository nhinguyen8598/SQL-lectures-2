USE [BikeStores]
GO

-- BT1
-- Viết truy vấn để lấy thông tin tên sản phẩm (product_name), mã đơn hàng (order_id), số lượng sản phẩm (quantity) 
-- và ngày đơn hàng đó được giao dịch (order_date)

-- Sau đó tạo 1 stored procedure để thực hiện việc lọc order_date trên tập dữ liệu vừa tạo theo ý muốn:
--     - nếu tìm thấy order_date: xuất kết quả bên trên theo order_date mà người dùng nhập
--     - nếu không tìm thấy order_date: xuất ra câu sau ('Không tìm thấy thông tin order_date trong hệ thống')

SELECT 
	p.[product_name]
	,i.[order_id]
	,i.[quantity]
	,o.[order_date]
FROM [production].[products] p
JOIN [sales].[order_items] i 
	ON p.[product_id] = i.[product_id]
JOIN [sales].[orders] o 
	ON i.[order_id] = o.[order_id]
WHERE [order_date] = '2017-07-01'
GO

CREATE PROCEDURE sp_GetSalesDatabyOrderDate
    @orderDate DATE
AS
BEGIN
    IF @orderDate NOT IN  (
                            SELECT
                                [order_date]
                            FROM [sales].[orders]
                        )
    BEGIN
        PRINT N'Không tìm thấy thông tin order_date trong hệ thống'
    END
    ELSE
    BEGIN
        SELECT 
            p.[product_name]
            ,i.[order_id]
            ,i.[quantity]
            ,o.[order_date]
        FROM [production].[products] p
        JOIN [sales].[order_items] i 
            ON p.[product_id] = i.[product_id]
        JOIN [sales].[orders] o 
            ON i.[order_id] = o.[order_id]
        WHERE o.[order_date] = @orderDate
    END
END
GO

EXEC sp_GetSalesDatabyOrderDate @orderDate = '2017-07-02'
GO
 ---C2 : 
  CREATE PROCEDURE sp_GetSalesDatabyOrderDate_1
  @order_date DATE = NULL 

  AS 
  BEGIN 
  IF  @order_date IS NULL 
   BEGIN
        SELECT 
            p.[product_name]
            ,i.[order_id]
            ,i.[quantity]
            ,o.[order_date]
        FROM [production].[products] p
        JOIN [sales].[order_items] i 
            ON p.[product_id] = i.[product_id]
        JOIN [sales].[orders] o 
            ON i.[order_id] = o.[order_id]
        WHERE @order_date IS NULL OR o.[order_date] = @order_date
        END 
        ELSE 
        PRINT N'Không tìm thấy thông tin order_date trong hệ thống'
    END
GO 

EXEC sp_GetSalesDatabyOrderDate @orderDate = '2017-07-01'
GO



-- BT2: Viết truy vấn lấy thông tin tên sản phẩm (product_name), giá của từng sản phẩm (list_price) và model_year.
-- Sau đó tạo 1 stored procedure để thực hiện việc lọc dữ liệu theo 2 tiêu chí:
--    - tên sản phẩm theo mẫu
--    - top bao nhiêu (top 1, 5, 10,...) sản phẩm có giá cao nhất theo model_year hoặc sản phẩm có giá cao với thứ hạng theo model_year 
--		(vd: sản phẩm có giá cao thứ 2 theo model_year)

SELECT
    product_name
    ,list_price
    ,model_year
FROM production.products
ORDER BY list_price DESC, model_year
GO

CREATE PROCEDURE sp_GetProductbyNameandRankingPrice
    @productNamePattern VARCHAR(255)
    ,@fromRank INT
    ,@toRank INT
    ,@modelYear INT = NULL
AS
BEGIN
    IF @modelYear IS NULL
    BEGIN
        WITH _TEMP
        AS 
        (
            SELECT
                product_name
                ,list_price
                ,model_year
                ,DENSE_RANK() OVER (PARTITION BY model_year ORDER BY list_price DESC) AS ranking
            FROM production.products
        )
        SELECT
            product_name
            ,list_price
            ,model_year
        FROM _TEMP
        WHERE product_name LIKE @productNamePattern
            AND ranking BETWEEN @fromRank AND @toRank
    END
    ELSE
    BEGIN
        WITH _TEMP
        AS 
        (
            SELECT
                product_name
                ,list_price
                ,model_year
                ,DENSE_RANK() OVER (PARTITION BY model_year ORDER BY list_price DESC) AS ranking
            FROM production.products
        )
        SELECT
            product_name
            ,list_price
            ,model_year
        FROM _TEMP
        WHERE product_name LIKE @productNamePattern
            AND ranking BETWEEN @fromRank AND @toRank
            AND model_year = @modelYear
    END
END
GO


--CÁCH 2 : 
CREATE PROCEDURE sp_GetProductbyNameandRankingPrice1
    @productNamePattern VARCHAR(255)
    ,@fromRank INT
    ,@toRank INT
    ,@modelYear INT = NULL
AS
    BEGIN
        WITH _TEMP
        AS 
        (
            SELECT
                product_name
                ,list_price
                ,model_year
                ,DENSE_RANK() OVER (PARTITION BY model_year ORDER BY list_price DESC) AS ranking
            FROM production.products
        )
        SELECT
            product_name
            ,list_price
            ,model_year
        FROM _TEMP
        WHERE product_name LIKE @productNamePattern
            AND ranking BETWEEN @fromRank AND @toRank
            AND (@modelYear IS NULL OR model_year = @modelYear)
              END
              GO 
-- DROP PROCEDURE sp_GetProductbyNameandRankingPrice1;
   -- EXEC sp_GetProductbyNameandRankingPrice @productNamePattern = '%', @fromRank = 1, @toRank = 1--@modelYear = 2016
   --GO

--EXEC sp_GetProductbyNameandRankingPrice @productNamePattern = '_%', @fromRank = 1, @toRank = 1--, @modelYear = 2016
--GO

EXEC sp_GetProductbyNameandRankingPrice @productNamePattern = '%', @fromRank = 1, @toRank = 1--, @modelYear = 2016
GO
-- BT3: Viết hàm để tính giá trị net value của mỗi chi tiết hóa đơn (order_id và item_id) 
--		biết net value được tính bằng công thức quantity * list_price * (1 - discount).



CREATE FUNCTION sales.udfNetSale(
    @quantity INT,
    @list_price DEC(10,2),
    @discount DEC(4,2)

)
RETURNS DEC(10,2)
AS
BEGIN
    RETURN @quantity * @list_price * (1 - @discount)
END
GO


-- BT4: Viết hàm để tính tống giá trị net value của mỗi hóa đơn (order_id) 
--		biết net value được tính bằng công thức quantity * list_price * (1 - discount).

CREATE FUNCTION [sales].[udfTotalNetSale](
    @order_id INT
)
RETURNS DEC(10,2)
AS
BEGIN
    DECLARE 
        @total DEC(10,2)

    SELECT
        @total = SUM([quantity] * [list_price] * (1 - [discount]))
    FROM [sales].[order_items]
    WHERE order_id = @order_id
    GROUP BY order_id

    RETURN @total
END
GO

-- hoặc

CREATE FUNCTION [sales].[udfTotalNetSale2](
    @order_id INT
)
RETURNS DEC(10,2)
AS
BEGIN
    DECLARE 
        @total DEC(10,2)

    SELECT
        @total = SUM(sales.udfNetSale([quantity], [list_price], [discount]))
    FROM [sales].[order_items]
    WHERE order_id = @order_id
    GROUP BY order_id

    RETURN @total
END
GO
--kiểm tra : 

SELECT  
[order_id]
,[sales].[udfTotalNetSale] (order_id ) as [total net sales]
FROM [BikeStores].[sales].[orders]
GO
  

-- BT5: Viết hàm để lấy tên sản phẩm (product_name) có giá trị cao nhất của mỗi hóa đơn (order_id).
CREATE FUNCTION [sales].[GetProductNameWithHighestNetValue](
    @order_id INT
)
RETURNS VARCHAR(255)
AS
BEGIN
    DECLARE 
        @product_name VARCHAR(255)

    SELECT 
        @product_name = [product_name]
    FROM
    (
        SELECT 
            [order_id]
            ,[product_name]
            ,ROW_NUMBER() OVER (PARTITION BY [order_id] ORDER BY sales.udfNetSale([quantity], OI.[list_price], [discount]) DESC) AS [ranking]
        FROM [sales].[order_items] OI
        JOIN [production].[products] P 
            ON OI.[product_id] = P.[product_id]
        WHERE [order_id] = @order_id
    ) a 
    WHERE a.[ranking] = 1

    RETURN @product_name
END
GO
 
--Kiểm tra 
SELECT  [order_id]
--,[sales].[udfTotalNetSale] (order_id ) as [total net sales]
    ,[sales].[GetProductNameWithHighestNetValue] (order_id)
      
  FROM [sales].[orders]
  GO
-- BT6: Viết hàm để tính tổng số lượng hàng ban đầu của mỗi cửa hàng trên mỗi sản phẩm (store_id và product_id) 
--		biết tống lượng hàng (quantity) ban đầu = số lượng hàng bán ra + số lượng hàng tồn kho.

CREATE FUNCTION [sales].[GetTotalQuantity](
    @store_id INT,
    @product_id INT

)
RETURNS INT
AS
BEGIN
    DECLARE 
        @total_quantity INT

    SELECT 
        @total_quantity = [quantity] + ISNULL([sale_quatity], 0)
    FROM [production].[stocks] S
    LEFT JOIN (
        SELECT 
            [store_id]
            ,OI.[product_id]
            ,SUM(OI.[quantity]) AS [sale_quatity]
        FROM [sales].[orders] O
        JOIN [sales].[order_items] OI 
            ON O.[order_id] = OI.[order_id]
        GROUP BY
            [store_id]
            ,OI.[product_id]
    ) O 
        ON S.[store_id] = O.[store_id]
        AND S.[product_id] = O.[product_id]
    WHERE S.[store_id] = @store_id
        AND S.[product_id] = @product_id

    RETURN @total_quantity
END
GO

---Kiểm tra 
SELECT  [store_id]
      ,[product_id]
      ,[quantity]
      , sales.GetTotalQuantity(store_id,product_id )
  FROM [BikeStores].[production].[stocks]