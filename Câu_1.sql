--Câu 1: Tạo database DoctorWho theo cấu trúc bảng và sơ đồ như trong file excel.

USE [master]
GO

CREATE DATABASE [DoctorWho]
GO

USE [DoctorWho]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblAuthor]') AND type in (N'U'))
DROP TABLE [dbo].[tblAuthor]
GO

CREATE TABLE [dbo].[tblAuthor](
	[AuthorId] [int] IDENTITY(1,1) NOT NULL,
	[AuthorName] [nvarchar](50) NULL,
	CONSTRAINT [PK_tblAuthor] PRIMARY KEY ([AuthorId])
)
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblCompanion]') AND type in (N'U'))
DROP TABLE [dbo].[tblCompanion]
GO

CREATE TABLE [dbo].[tblCompanion](
	[CompanionId] [int] IDENTITY(1,1) NOT NULL,
	[CompanionName] [nvarchar](50) NOT NULL,
	[WhoPlayed] [nvarchar](50) NULL,
	CONSTRAINT [PK_tblCompanion] PRIMARY KEY ([CompanionId])
)
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblDoctor]') AND type in (N'U'))
DROP TABLE [dbo].[tblDoctor]
GO

CREATE TABLE [dbo].[tblDoctor](
	[DoctorId] [int] IDENTITY(1,1) NOT NULL,
	[DoctorNumber] [int] NULL,
	[DoctorName] [nvarchar](50) NULL,
	[BirthDate] [date] NULL,
	[FirstEpisodeDate] [date] NULL,
	[LastEpisodeDate] [date] NULL,
	CONSTRAINT [PK_tblDoctor] PRIMARY KEY ([DoctorId])
)
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEnemy]') AND type in (N'U'))
DROP TABLE [dbo].[tblEnemy]
GO

CREATE TABLE [dbo].[tblEnemy](
	[EnemyId] [int] IDENTITY(1,1) NOT NULL,
	[EnemyName] [nvarchar](100) NULL,
	[Description] [nvarchar](255) NULL,
	CONSTRAINT [PK_tblEnemy] PRIMARY KEY ([EnemyId])
)
GO

ALTER TABLE [dbo].[tblEpisode] DROP CONSTRAINT [FK_tblEpisode_tblDoctor]
GO

ALTER TABLE [dbo].[tblEpisode] DROP CONSTRAINT [FK_tblEpisode_tblAuthor]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEpisode]') AND type in (N'U'))
DROP TABLE [dbo].[tblEpisode]
GO

CREATE TABLE [dbo].[tblEpisode](
	[EpisodeId] [int] IDENTITY(1,1) NOT NULL,
	[SeriesNumber] [int] NULL,
	[EpisodeNumber] [int] NULL,
	[EpisodeType] [nvarchar](50) NULL,
	[Title] [nvarchar](255) NULL,
	[EpisodeDate] [date] NULL,
	[AuthorId] [int] NULL,
	[DoctorId] [int] NULL,
	[Notes] [nvarchar](255) NULL,
	CONSTRAINT [PK_tblEpisode] PRIMARY KEY ([EpisodeId]),
	CONSTRAINT [FK_tblEpisode_tblAuthor] FOREIGN KEY([AuthorId]) 
		REFERENCES [dbo].[tblAuthor] ([AuthorId]) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT [FK_tblEpisode_tblDoctor] FOREIGN KEY([DoctorId]) 
		REFERENCES [dbo].[tblDoctor] ([DoctorId]) ON UPDATE CASCADE ON DELETE CASCADE
)
GO

ALTER TABLE [dbo].[tblEpisodeCompanion] DROP CONSTRAINT [FK_tblEpisodeCompanion_tblEpisode]
GO

ALTER TABLE [dbo].[tblEpisodeCompanion] DROP CONSTRAINT [FK_tblEpisodeCompanion_tblCompanion]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEpisodeCompanion]') AND type in (N'U'))
DROP TABLE [dbo].[tblEpisodeCompanion]
GO

CREATE TABLE [dbo].[tblEpisodeCompanion](
	[EpisodeCompanionId] [int] IDENTITY(1,1) NOT NULL,
	[EpisodeId] [int] NULL,
	[CompanionId] [int] NULL,
	CONSTRAINT [PK_tblEpisodeCompanion] PRIMARY KEY ([EpisodeCompanionId]),
	CONSTRAINT [FK_tblEpisodeCompanion_tblCompanion] FOREIGN KEY([CompanionId]) 
		REFERENCES [dbo].[tblCompanion] ([CompanionId]) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT [FK_tblEpisodeCompanion_tblEpisode] FOREIGN KEY([EpisodeId]) 
		REFERENCES [dbo].[tblEpisode] ([EpisodeId]) ON UPDATE CASCADE ON DELETE CASCADE
)
GO

ALTER TABLE [dbo].[tblEpisodeEnemy] DROP CONSTRAINT [FK_tblEpisodeEnemy_tblEpisode]
GO

ALTER TABLE [dbo].[tblEpisodeEnemy] DROP CONSTRAINT [FK_tblEpisodeEnemy_tblEnemy]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEpisodeEnemy]') AND type in (N'U'))
DROP TABLE [dbo].[tblEpisodeEnemy]
GO

CREATE TABLE [dbo].[tblEpisodeEnemy](
	[EpisodeEnemyId] [int] IDENTITY(1,1) NOT NULL,
	[EpisodeId] [int] NULL,
	[EnemyId] [int] NULL,
	CONSTRAINT [PK_tblEpisodeEnemy] PRIMARY KEY ([EpisodeEnemyId]),
	CONSTRAINT [FK_tblEpisodeEnemy_tblEnemy] FOREIGN KEY([EnemyId])
		REFERENCES [dbo].[tblEnemy] ([EnemyId]) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT [FK_tblEpisodeEnemy_tblEpisode] FOREIGN KEY([EpisodeId]) 
		REFERENCES [dbo].[tblEpisode] ([EpisodeId]) ON UPDATE CASCADE ON DELETE CASCADE
)
GO