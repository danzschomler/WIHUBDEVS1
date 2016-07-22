SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_TruncateDailyData] AS

Declare @Return bit; Set @Return = 0

	--Truncate Table allSARole
	Truncate Table localDatabaseInfo
	Truncate Table localDiskSpace
	Truncate Table localFileInfo
	Truncate Table localLinkedServer
	Truncate Table localOrphanUsers
	Truncate Table localRolemember
	Truncate Table localServerInfo
	Truncate Table localTableInfo
	Truncate Table localConfigData
	Truncate Table localAgentJobs
	Truncate Table localSALogins
	Truncate Table localDatabaseSecurables 
	Truncate Table localPermissions
	TRUNCATE TABLE localPerfMonData
	TRUNCATE TABLE localFailedJobs

If @@ERROR <> 0 
	Set @Return = 0
	Else
	Set @Return = 1 

RETURN @Return

GO
