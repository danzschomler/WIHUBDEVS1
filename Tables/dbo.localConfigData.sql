CREATE TABLE [dbo].[localConfigData]
(
[ConfigurationID] [int] NOT NULL,
[Name] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [sql_variant] NULL,
[ValueInUse] [sql_variant] NULL,
[CaptureDate] [datetime] NULL,
[ServerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
