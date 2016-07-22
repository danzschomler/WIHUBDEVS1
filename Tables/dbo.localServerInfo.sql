CREATE TABLE [dbo].[localServerInfo]
(
[ServerName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServerOwner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgentOwner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Processors] [int] NULL,
[Uptime] [int] NULL,
[Memory] [int] NULL,
[ServicePatch] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Edition] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductVersion] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Platform] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WindowsVersion] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Collation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IPAddress] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaptureDate] [datetime] NULL
) ON [PRIMARY]
GO
