SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[usp_UpdateServerName] as


Update DBA_Maint.dbo.localAgentJobs Set ServerName = @@SERVERNAME 
Update DBA_Maint.dbo.localConfigData Set ServerName = @@SERVERNAME 
Update DBA_Maint.dbo.localDatabaseInfo Set ServerName = @@SERVERNAME 
Update DBA_Maint.dbo.localDatabaseSecurables Set ServerName = @@SERVERNAME 
Update DBA_Maint.dbo.localDiskSpace Set ServerName = @@SERVERNAME 
Update DBA_Maint.dbo.localFailedJobs Set ServerName = @@SERVERNAME 
Update DBA_Maint.dbo.localFileInfo Set ServerName = @@SERVERNAME 
Update DBA_Maint.dbo.localJobHistory Set ServerName = @@SERVERNAME 
Update DBA_Maint.dbo.localLinkedServer Set ServerName = @@SERVERNAME 
Update DBA_Maint.dbo.localOrphanUsers Set ServerName = @@SERVERNAME 
Update DBA_Maint.dbo.localPerfMonData Set ServerName = @@SERVERNAME 
Update DBA_Maint.dbo.localPermissions Set ServerName = @@SERVERNAME 
Update DBA_Maint.dbo.localRolemember Set ServerName = @@SERVERNAME 
Update DBA_Maint.dbo.localSALogins Set ServerName = @@SERVERNAME 
Update DBA_Maint.dbo.localServerInfo Set ServerName = @@SERVERNAME 
Update DBA_Maint.dbo.localTableInfo Set ServerName = @@SERVERNAME 


GO
