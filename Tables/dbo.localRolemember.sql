CREATE TABLE [dbo].[localRolemember]
(
[DatabaseName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RoleName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaptureDate] [datetime] NULL,
[ServerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
