--Câu 6: Viết 1 view với cấu trúc như bảng ở câu 4 nhưng thêm 3 cột sau:
--	-	NextCompanions: những nhân vật đồng hành trong tập (EpisodeNumber) sau.
--	-	NextEnemies: những nhân vật phản diện trong tập sau.
--	-	HowLongIsOneSeason: thời gian của 1 SeriesNumber (tính theo tháng)

USE [DoctorWho]
GO

CREATE VIEW [dbo].[vw_Summary_2]
AS
WITH _TEMP
AS
(
	SELECT 
		[SeriesNumber]
		,[EpisodeNumber]
		,[Title]
		,[EpisodeDate]
		,[AuthorName]
		,[DoctorName]
		,[Companions] 
		,LEAD([Companions]) OVER (PARTITION BY [SeriesNumber] ORDER BY [EpisodeNumber]) AS [NextCompanions]
		,[Enemies]
		,LEAD([Enemies]) OVER (PARTITION BY [SeriesNumber] ORDER BY [EpisodeNumber]) AS [NextEnemies]
		,MIN([EpisodeDate]) OVER (PARTITION BY [SeriesNumber] ORDER BY [EpisodeNumber]) AS [MinSeasonDate]
		,MAX([EpisodeDate]) OVER (PARTITION BY [SeriesNumber] ORDER BY [EpisodeNumber] DESC) AS [MaxSeasonDate]
	FROM [dbo].[vw_Summary]
)
SELECT
	[SeriesNumber]
	,[EpisodeNumber]
	,[Title]
	,[EpisodeDate]
	,[AuthorName]
	,[DoctorName]
	,[Companions] 
	,[NextCompanions]
	,[Enemies]
	,[NextEnemies]
	--,[MinSeasonDate]
	--,[MaxSeasonDate]
	,DATEDIFF(MONTH, [MinSeasonDate], [MaxSeasonDate]) AS [HowLongIsOneSeason_months]
FROM _TEMP