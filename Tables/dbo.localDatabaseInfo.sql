CREATE TABLE [dbo].[localDatabaseInfo]
(
[DatabaseName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatabaseOwner] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL,
[RecoveryMode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Coallition] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatabaseStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastbackupType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastBackupDate] [datetime] NULL,
[LastLogBackupDate] [datetime] NULL,
[CaptureDate] [datetime] NULL,
[ServerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AlwaysOnRole] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
