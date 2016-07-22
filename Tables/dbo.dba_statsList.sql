CREATE TABLE [dbo].[dba_statsList]
(
[Counter] [decimal] (18, 0) NOT NULL IDENTITY(1, 1),
[databaseName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatsName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[datetimeStart] [datetime] NULL,
[datetimeEnd] [datetime] NULL,
[durationSeconds] [int] NULL,
[SQLStatement] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dba_statsList] ADD CONSTRAINT [PK_dba_statsList] PRIMARY KEY CLUSTERED  ([Counter]) ON [PRIMARY]
GO
