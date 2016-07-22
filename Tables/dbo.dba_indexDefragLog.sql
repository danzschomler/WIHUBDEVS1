CREATE TABLE [dbo].[dba_indexDefragLog]
(
[indexDefrag_id] [int] NOT NULL IDENTITY(1, 1),
[databaseID] [int] NOT NULL,
[databaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[objectID] [int] NOT NULL,
[objectName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[indexID] [int] NOT NULL,
[indexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[partitionNumber] [smallint] NOT NULL,
[fragmentation] [float] NOT NULL,
[page_count] [int] NOT NULL,
[dateTimeStart] [datetime] NOT NULL,
[dateTimeEnd] [datetime] NULL,
[durationSeconds] [int] NULL,
[sqlStatement] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[errorMessage] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dba_indexDefragLog] ADD CONSTRAINT [PK_indexDefragLog_v40] PRIMARY KEY CLUSTERED  ([indexDefrag_id]) ON [PRIMARY]
GO
