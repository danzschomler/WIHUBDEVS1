SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_CollectPermissions] AS

SET NOCOUNT ON;

DECLARE @cmdstr nvarchar(1000)
DECLARE @DbName nvarchar(100)
Declare @Return bit; Set @Return = 0

	Declare cs_t cursor for
		--Select [name] from master.dbo.sysdatabases where dbid > 4 and version > 0
		Select [name] FROM master.sys.databases Where state_desc = 'ONLINE' and database_id > 4

	open cs_t
		fetch next from cs_t into @DbName
		while @@FETCH_STATUS = 0
		begin

		Set @cmdstr = 'Use [' + @dbName + '] Insert Into DBA_Maint.dbo.localPermissions(DatabaseName, Object, UserName, Permission, CaptureDate) ' +
			'Select DB_Name(), OBJECT_NAME(major_id) as [Object], USER_NAME(grantee_principal_id) as [UserName], permission_name, GetDate() ' +
			'FROM sys.database_permissions p ' +
			'WHERE	p.class = 1 AND state_desc = ''GRANT'' and USER_NAME(grantee_principal_id) <> ''public'' AND OBJECT_NAME(major_id) <> ''sp_syspolicy_execute_policy'' ' +
			'ORDER BY OBJECT_NAME(major_id), USER_NAME(grantee_principal_id), permission_name  '
		
		--PRINT @cmdstr
		EXEC sp_executesql @cmdstr
		fetch next from cs_t into @DbName
		end

	close cs_t
	deallocate cs_t

RETURN @Return

GO
