CREATE TABLE [dbo].[dba_indexDefragExclusion]
(
[databaseID] [int] NOT NULL,
[databaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[objectID] [int] NOT NULL,
[objectName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[indexID] [int] NOT NULL,
[indexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[exclusionMask] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dba_indexDefragExclusion] ADD CONSTRAINT [PK_indexDefragExclusion_v40] PRIMARY KEY CLUSTERED  ([databaseID], [objectID], [indexID]) ON [PRIMARY]
GO
