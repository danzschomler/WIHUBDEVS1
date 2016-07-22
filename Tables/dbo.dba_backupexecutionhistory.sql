CREATE TABLE [dbo].[dba_backupexecutionhistory]
(
[Counter] [decimal] (18, 0) NOT NULL IDENTITY(1, 1),
[SQLCommand] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[datetimeStart] [datetime] NULL,
[datetimeEnd] [datetime] NULL,
[durationSeconds] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
