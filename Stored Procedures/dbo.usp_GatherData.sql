SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_GatherData] AS

SET NOCOUNT ON;

exec [dbo].[usp_TruncateDailyData]
exec [dbo].[usp_CollectAgentData] 
exec [dbo].[usp_CollectConfigData]
exec [dbo].[usp_CollectDatabaseInfo]
--exec [dbo].[usp_CollectDatabaseSecurables] *
exec [dbo].[usp_CollectFileInfo]
exec [dbo].[usp_CollectLinkedServers]  
exec [dbo].[usp_CollectlocalDiskSpace]		
--exec [dbo].[usp_CollectOrphanUsers]  
--exec [dbo].[usp_CollectPerfMonData]
exec [dbo].[usp_CollectPermissions]
--exec [dbo].[usp_CollectRolemember]
exec [dbo].[usp_CollectSALogins]
exec [dbo].[usp_CollectServerInfo]
exec [dbo].[usp_CollectTableInfo]
EXEC [dbo].[usp_CollectFailedJobs]

EXEC [dbo].[usp_UpdateServerName]
GO
