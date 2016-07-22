CREATE TABLE [dbo].[localDiskSpace]
(
[Drive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalSize_GB] [float] NULL,
[FreeSpace_GB] [float] NULL,
[FreeSpace_Percent] [int] NULL,
[CaptureDate] [datetime] NOT NULL,
[ServerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
