CREATE TABLE [dbo].[dba_indexDefragStatus]
(
[databaseID] [int] NOT NULL,
[databaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[objectID] [int] NOT NULL,
[indexID] [int] NOT NULL,
[partitionNumber] [smallint] NOT NULL,
[fragmentation] [float] NOT NULL,
[page_count] [int] NOT NULL,
[range_scan_count] [bigint] NOT NULL,
[schemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[objectName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[indexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scanDate] [datetime] NOT NULL,
[defragDate] [datetime] NULL,
[printStatus] [bit] NOT NULL CONSTRAINT [DF__dba_index__print__3A81B327] DEFAULT ((0)),
[exclusionMask] [int] NOT NULL CONSTRAINT [DF__dba_index__exclu__3B75D760] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dba_indexDefragStatus] ADD CONSTRAINT [PK_indexDefragStatus_v40] PRIMARY KEY CLUSTERED  ([databaseID], [objectID], [indexID], [partitionNumber]) ON [PRIMARY]
GO
