CREATE TABLE [dbo].[localFileInfo]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[FileID] [int] NOT NULL,
[Type] [tinyint] NOT NULL,
[DriveLetter] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogicalFileName] [sys].[sysname] NOT NULL,
[PhysicalFileName] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SizeMB] [decimal] (38, 2) NULL,
[SpaceUsedMB] [decimal] (38, 2) NULL,
[FreeSpaceMB] [decimal] (38, 2) NULL,
[MaxSize] [decimal] (38, 2) NULL,
[IsPercentGrowth] [bit] NULL,
[Growth] [decimal] (38, 2) NULL,
[CaptureDate] [datetime] NOT NULL,
[ServerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
