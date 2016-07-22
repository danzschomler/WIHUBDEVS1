CREATE TABLE [dbo].[localAgentJobs]
(
[JobName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobOwner] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobCategory] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobDescription] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsEnabled] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobCreatedOn] [datetime] NULL,
[JobLastModifiedOn] [datetime] NULL,
[OriginatingServerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsScheduled] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobScheduleName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaptureDate] [datetime] NULL,
[ServerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
