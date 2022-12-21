-- Câu 4: Viết 1 view để lấy toàn bộ nội dung của truy vấn ở câu 4.
CREATE VIEW [dbo].[vw_Summary]
AS
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