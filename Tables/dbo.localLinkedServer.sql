CREATE TABLE [dbo].[localLinkedServer]
(
[LinkServer] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocalLogin] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSelfMapping] [bit] NULL,
[RemoteLogin] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaptureDate] [datetime] NULL,
[ServerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
