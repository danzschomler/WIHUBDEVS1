CREATE TABLE [dbo].[localDatabaseSecurables]
(
[DatabaseName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserType] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatabaseUserName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Role] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PermissionState] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PermissionType] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ObjectType] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ObjectName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaptureDate] [datetime] NULL,
[ServerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
