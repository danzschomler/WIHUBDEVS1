CREATE TABLE [dbo].[localJobHistory]
(
[JobID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobStatus] [int] NULL,
[RunDateTime] [datetime] NULL,
[RunDurationInSec] [int] NULL,
[CaptureDate] [datetime] NULL,
[ServerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
