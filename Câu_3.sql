--Câu 3: Viết 1 hàm table-valued để khi người dùng nhập thông tin SeriesNumber và EpisodeNumber, 
--			hàm sẽ trả về kết quả như bảng dưới đây. 

USE [DoctorWho]
GO

CREATE FUNCTION [dbo].[udf_Summary](
	@seriesNumber INT
	,@episodeNumber INT
)
RETURNS TABLE
AS
RETURN
	SELECT 
		[SeriesNumber]
		,[EpisodeNumber]
		,[Title]
		,[EpisodeDate]
		,a.[AuthorName]
		,d.[DoctorName]
		,[dbo].[udf_Companions](e.[EpisodeId]) AS [Companions]
		,[dbo].[udf_Enemies](e.[EpisodeId]) AS [Enemies]
	FROM [dbo].[tblEpisode] e
	INNER JOIN [dbo].[tblAuthor] a 
		ON a.[AuthorId] = e.[AuthorId]
	INNER JOIN [dbo].[tblDoctor] d 
		ON e.[DoctorId] = d.[DoctorId]
	WHERE [SeriesNumber] = @seriesNumber
		AND [EpisodeNumber] = @episodeNumber
GO

--SELECT * FROM [dbo].[udf_Summary] (1, 1)