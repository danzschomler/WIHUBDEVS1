CREATE TABLE [dbo].[localPerfMonData]
(
[Counter] [nvarchar] (770) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Value] [decimal] (38, 2) NULL,
[CaptureDate] [datetime] NULL,
[ServerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
