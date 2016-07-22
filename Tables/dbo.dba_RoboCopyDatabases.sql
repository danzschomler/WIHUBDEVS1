CREATE TABLE [dbo].[dba_RoboCopyDatabases]
(
[Counter] [decimal] (18, 0) NOT NULL IDENTITY(1, 1),
[DatabaseName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IPGSpeed] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dba_RoboCopyDatabases] ADD CONSTRAINT [PK_dba_RoboCopyDatabases] PRIMARY KEY CLUSTERED  ([Counter]) ON [PRIMARY]
GO
