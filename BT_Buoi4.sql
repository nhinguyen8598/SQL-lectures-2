USE [BikeStores]
GO

-- BT1: Tạo 1 bảng sales.customers_audit, viết các trigger để lưu trữ thông tin thay đổi cho các hành động INSERT, UPDATE, DELETE trên bảng sales.customers

CREATE TABLE [sales].[customers_audit](
    [change_id] [int] IDENTITY PRIMARY KEY,
	[customer_id] [int] NOT NULL,
	[first_name] [varchar](255) NOT NULL,
	[last_name] [varchar](255) NOT NULL,
	[phone] [varchar](25) NULL,
	[email] [varchar](255) NOT NULL,
	[street] [varchar](255) NULL,
	[city] [varchar](50) NULL,
	[state] [varchar](25) NULL,
	[zip_code] [varchar](5) NULL,
    [updated_at] [datetime] NOT NULL,
    [operation] [varchar](10) NOT NULL,
    CHECK([operation] IN ('INS', 'UPD-NEW', 'UPD-REMOVE', 'DEL'))
)
GO

CREATE TRIGGER [sales].[trg_customer_audit_INSERT_DELETE]
ON [sales].[customers]
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [sales].[customers_audit](
        [customer_id],
		[first_name],
		[last_name],
		[phone],
		[email],
		[street],
		[city],
		[state],
		[zip_code],
		[updated_at],
		[operation]
    )
    SELECT
       	[customer_id]
		,[first_name]
		,[last_name]
		,[phone]
		,[email]
		,[street]
		,[city]
		,[state]
		,[zip_code]
        ,GETDATE()
		,'INS'
    FROM
        inserted i

    UNION ALL

    SELECT
       	[customer_id]
		,[first_name]
		,[last_name]
		,[phone]
		,[email]
		,[street]
		,[city]
		,[state]
		,[zip_code]
        ,GETDATE()
		,'DEL'
    FROM
        deleted d
END
GO

CREATE TRIGGER [sales].[trg_customer_audit_UPDATE]
ON [sales].[customers]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [sales].[customers_audit](
        [customer_id],
		[first_name],
		[last_name],
		[phone],
		[email],
		[street],
		[city],
		[state],
		[zip_code],
		[updated_at],
		[operation]
    )
    SELECT
       	[customer_id]
		,[first_name]
		,[last_name]
		,[phone]
		,[email]
		,[street]
		,[city]
		,[state]
		,[zip_code]
        ,GETDATE()
		,'UPD-NEW'
    FROM
        inserted i

    UNION ALL

    SELECT
       	[customer_id]
		,[first_name]
		,[last_name]
		,[phone]
		,[email]
		,[street]
		,[city]
		,[state]
		,[zip_code]
        ,GETDATE()
		,'UPD-REMOVE'
    FROM
        deleted d
END


INSERT INTO [sales].[customers]
           ([first_name]
           ,[last_name]
           ,[phone]
           ,[email]
           ,[street]
           ,[city]
           ,[state]
           ,[zip_code])
     VALUES
           ('John'
           ,'Doe'
           ,'0123-456-789'
           ,'john.doe@email.com'
           ,'ABC'
           ,'ABC'
           ,'ABC'
           ,'ABC')
GO

UPDATE [sales].[customers]
SET [first_name] = 'Jane'
WHERE [first_name] = 'John'	
	AND [last_name] = 'Doe'
GO

DELETE FROM [sales].[customers]
WHERE [first_name] = 'Jane'	
	AND [last_name] = 'Doe'

-- BT2: Tạo 1 bảng sales.staffs_audit, viết các trigger để lưu trữ thông tin thay đổi cho các hành động INSERT, UPDATE, DELETE trên bảng sales.staffs

CREATE TABLE [sales].[staffs_audit](
    [change_id] [int] IDENTITY PRIMARY KEY,
	[staff_id] [int] NOT NULL,
	[first_name] [varchar](50) NOT NULL,
	[last_name] [varchar](50) NOT NULL,
	[email] [varchar](255) NOT NULL,
	[phone] [varchar](25) NULL,
	[active] [tinyint] NOT NULL,
	[store_id] [int] NOT NULL,
	[manager_id] [int] NULL,
    [updated_at] [datetime] NOT NULL,
    [operation] [varchar](10) NOT NULL,
    CHECK([operation] IN ('INS', 'UPD-NEW', 'UPD-REMOVE', 'DEL'))
)
GO


CREATE TRIGGER [sales].[trg_staffs_audit_INSERT_DELETE]
ON [sales].[staffs]
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [sales].[staffs_audit](
        [staff_id]
        ,[first_name]
        ,[last_name]
        ,[email]
        ,[phone]
        ,[active]
        ,[store_id]
        ,[manager_id]
		,[updated_at]
        ,[operation]
    )
    SELECT
       	[staff_id]
        ,[first_name]
        ,[last_name]
        ,[email]
        ,[phone]
        ,[active]
        ,[store_id]
        ,[manager_id]
        ,GETDATE()
		,'INS'
    FROM
        inserted i

    UNION ALL

    SELECT
       	[staff_id]
        ,[first_name]
        ,[last_name]
        ,[email]
        ,[phone]
        ,[active]
        ,[store_id]
        ,[manager_id]
        ,GETDATE()
		,'DEL'
    FROM
        deleted d
END
GO

CREATE TRIGGER [sales].[trg_staffs_audit_UPDATE]
ON [sales].[staffs]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [sales].[staffs_audit](
        [staff_id]
        ,[first_name]
        ,[last_name]
        ,[email]
        ,[phone]
        ,[active]
        ,[store_id]
        ,[manager_id]
		,[updated_at]
        ,[operation]
    )
    SELECT
       	[staff_id]
        ,[first_name]
        ,[last_name]
        ,[email]
        ,[phone]
        ,[active]
        ,[store_id]
        ,[manager_id]
        ,GETDATE()
		,'UPD-NEW'
    FROM
        inserted i

    UNION ALL

    SELECT
       	[staff_id]
        ,[first_name]
        ,[last_name]
        ,[email]
        ,[phone]
        ,[active]
        ,[store_id]
        ,[manager_id]
        ,GETDATE()
		,'UPD-REMOVE'
    FROM
        deleted d
END


INSERT INTO [sales].[staffs]
           ([first_name]
            ,[last_name]
            ,[email]
            ,[phone]
            ,[active]
            ,[store_id]
            ,[manager_id])
     VALUES
           ('Jane'
           ,'Doe'
           ,'jane.doe@email.com'
           ,'0123-456-789'
           ,1
           ,1
           ,2)
GO

UPDATE [sales].[staffs]
SET [first_name] = 'John'
WHERE [first_name] = 'Jane'	
	AND [last_name] = 'Doe'
GO

DELETE FROM [sales].[staffs]
WHERE [first_name] = 'John'	
	AND [last_name] = 'Doe'