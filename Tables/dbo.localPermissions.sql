CREATE TABLE [dbo].[localPermissions]
(
[DatabaseName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Object] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Permission] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaptureDate] [datetime] NULL,
[ServerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
