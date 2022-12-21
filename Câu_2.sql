--Câu 2: Viết 2 hàm scalar-valued để trả về:
--	- Danh sách các nhân vật đồng hành (Companions), ví dụ: Amy Pond, Rory Williams
--	- Danh sách các nhân vật phản diện (Enemy), ví dụ: Kahler-Jex, Kahler-Tek

USE [DoctorWho]
GO

CREATE FUNCTION [dbo].[udf_Companions](
	@EpisodeId INT
)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @c VARCHAR(100) = ''

	SELECT
		@c = @c + CASE WHEN LEN(@c) > 0 THEN ', ' ELSE '' END + c.[CompanionName]
	FROM [dbo].[tblEpisodeCompanion] ec
	INNER JOIN [dbo].[tblCompanion] c 
		ON ec.[CompanionId] = c.[CompanionId]
	WHERE ec.[EpisodeId] = @EpisodeId

	RETURN @c
END
GO

CREATE FUNCTION [dbo].[udf_Enemies](
	@EpisodeId INT
)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @c VARCHAR(100) = ''

	SELECT
		@c = @c + CASE WHEN LEN(@c) > 0 THEN ', ' ELSE '' END + c.[EnemyName]
	FROM [dbo].[tblEpisodeEnemy] ec
	INNER JOIN [dbo].[tblEnemy] c 
		ON ec.[EnemyId] = c.[EnemyId]
	WHERE ec.[EpisodeId] = @EpisodeId

	RETURN @c
END
GO