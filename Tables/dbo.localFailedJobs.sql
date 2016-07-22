CREATE TABLE [dbo].[localFailedJobs]
(
[JobName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StepName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLSeverity] [int] NULL,
[Message] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunDate] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunTime] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaptureDate] [datetime] NULL,
[ServerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
