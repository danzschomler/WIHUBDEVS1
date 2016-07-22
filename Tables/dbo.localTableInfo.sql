CREATE TABLE [dbo].[localTableInfo]
(
[DatabaseName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Row_Count] [decimal] (18, 0) NULL,
[TableSize_MB] [decimal] (18, 0) NULL,
[DataSpaceUsed_MB] [decimal] (18, 0) NULL,
[IndexSpaceUsed_MB] [decimal] (18, 0) NULL,
[UnusedSpace_MB] [decimal] (18, 0) NULL,
[CaptureDate] [datetime] NULL,
[ServerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
