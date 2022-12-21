
USE [HistoricalEvents]
GO

-- Câu 1
SELECT 
    [CountryName]
FROM [dbo].[tblCountry] c
LEFT JOIN [dbo].[tblEvent] e
	ON C.[CountryId] = E.[CountryId]
WHERE E.[CountryId] IS NULL

-- Câu 2
SELECT
	c.[CountryName] AS [Country Name] 
	,COUNT(*) AS [Number of events]
FROM [dbo].[tblCountry] c
INNER JOIN [dbo].[tblEvent] e 
	ON c.[CountryId] = e.[CountryId]
WHERE YEAR(e.[EventDate]) >= 1990
GROUP BY
	c.[CountryName]
HAVING COUNT(*) >= 5

-- Câu 3
SELECT 
	DATENAME(weekday,[EventDate]) + ', ' 
		+ DATENAME(d,[EventDate]) + ' ' 
		+ DATENAME(m,[EventDate]) + ' ' 
		+ DATENAME(yy,[EventDate])
	AS [EventDate]
	,CASE
		WHEN YEAR([EventDate]) <= 1949 THEN '40s'
		WHEN YEAR([EventDate]) <= 1959 THEN '50s'
		WHEN YEAR([EventDate]) <= 1969 THEN '60s'
		WHEN YEAR([EventDate]) <= 1979 THEN '70s'
		END AS [Decade]
	,[CountryName]
	,[EventName]
FROM
	[dbo].[tblEvent] E
JOIN [dbo].[tblCountry] C
ON E.[CountryId] = C.[CountryId]
WHERE [EventName] like '%WAR%'
	AND YEAR(EventDate) <= 1975

-- Câu 4
SELECT
	[EventName]
	,[EventDate]
	,[CountryName]
FROM [dbo].[tblEvent] e
JOIN [dbo].[tblCountry] c
	ON e.[CountryId] = c.[CountryId]
WHERE [EventDate] > (
						SELECT MAX([EventDate])
						FROM [dbo].[tblEvent]
						WHERE [CountryId] = 19
					)