-- Câu 5: Viết 1 stored procedure trả về kết quả tra cứu giống cấu trúc như bảng ở câu 4 
--		khi người dùng nhập thông tin AuthorName, DoctorName, Companions, Enemies 
--		(lưu ý là người dùng có thể nhập thông tin toàn bộ 4 cột hoặc chỉ nhập thông tin cho 1 vài cột). 
--		Người dùng có thể chọn tìm kiếm chính xác thông tin nhập hoặc có chứa thông tin họ nhập.

USE [DoctorWho]
GO

CREATE PROCEDURE [dbo].[FindDatainSummary]
	@authorName NVARCHAR(50) = NULL
	,@doctorName NVARCHAR(50) = NULL
	,@companions VARCHAR(100) = NULL
	,@enemies VARCHAR(100) = NULL
	,@findExact TINYINT = 1
AS
BEGIN
	IF @findExact = 1
	BEGIN
		SELECT 
			[SeriesNumber]
			,[EpisodeNumber]
			,[Title]
			,[EpisodeDate]
			,[AuthorName]
			,[DoctorName]
			,[Companions]
			,[Enemies]
		FROM [dbo].[vw_Summary]
		WHERE 
			(@authorName IS NULL OR [AuthorName] = @authorName) 
			AND (@doctorName IS NULL OR [DoctorName] = @doctorName)
			AND (@companions IS NULL OR [Companions] = @companions)
			AND (@enemies IS NULL OR [Enemies] = @enemies)
	END
	ELSE 
	BEGIN
		SELECT 
			[SeriesNumber]
			,[EpisodeNumber]
			,[Title]
			,[EpisodeDate]
			,[AuthorName]
			,[DoctorName]
			,[Companions]
			,[Enemies]
		FROM [dbo].[vw_Summary]
		WHERE 
			(@authorName IS NULL OR [AuthorName] LIKE @authorName) 
			AND (@doctorName IS NULL OR [DoctorName] LIKE @doctorName)
			AND (@companions IS NULL OR [Companions] LIKE @companions)
			AND (@enemies IS NULL OR [Enemies] LIKE @enemies)
	END  
END

EXEC [dbo].[FindDatainSummary]
EXEC [dbo].[FindDatainSummary] @authorName = 'Russell T. Davies'
EXEC [dbo].[FindDatainSummary] @authorName = 'Russell T. Davies', @doctorName = 'Christopher Eccleston'
EXEC [dbo].[FindDatainSummary] @doctorName = 'Christopher Eccleston', @companions = 'Rose Tyler'
EXEC [dbo].[FindDatainSummary] @enemies = 'Lady Cassandra', @companions = 'Rose Tyler'

EXEC [dbo].[FindDatainSummary] @companions = '%Rose%', @findExact = 0