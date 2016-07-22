SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_CollectDatabaseSecurables] AS
Declare @Return bit; Set @Return = 0
Declare @hope nvarchar(1000)

BEGIN TRANSACTION

BEGIN TRY

Declare @ssql nvarchar(MAX)

Set @ssql = '
Insert Into DBA_Maint.dbo.localDatabaseSecurables(DatabaseName, UserName, UserType, DatabaseUserName, PermissionState, PermissionType, ObjectType, ObjectName, CaptureDate)
SELECT ''?'' as DatabaseName,
	   [UserName] = ulogin.[name],
       [UserType]             = CASE princ.[type]
                         WHEN ''S'' THEN ''SQL User''
                         WHEN ''U'' THEN ''Windows User''
                         WHEN ''G'' THEN ''Windows Group''
                    END,
       [DatabaseUserName]     = princ.[name],
       --[Role]                 = NULL,
       [PermissionState]      = perm.[state_desc],
       [PermissionType]       = perm.[permission_name],
       [ObjectType]           = CASE perm.[class]
                           WHEN 1 THEN obj.type_desc 
                           ELSE perm.[class_desc] 
                      END,
       [ObjectName]           = CASE perm.[class]
                           WHEN 1 THEN OBJECT_NAME(perm.major_id,DB_ID(''?'')) 
                           WHEN 3 THEN schem.[name] 
                           WHEN 4 THEN imp.[name] 
                      END,
		GetDate() 

FROM   [?].sys.database_principals princ			 
       LEFT JOIN [?].sys.server_principals ulogin		ON  princ.[sid] = ulogin.[sid]
       LEFT JOIN [?].sys.database_permissions perm		ON  perm.[grantee_principal_id] = princ.[principal_id]
       LEFT JOIN [?].sys.columns col					ON  col.[object_id] = perm.major_id 
			AND col.[column_id] = perm.[minor_id]
       LEFT JOIN [?].sys.objects obj					ON  perm.[major_id] = obj.[object_id]
       LEFT JOIN [?].sys.schemas schem					ON  schem.[schema_id] = perm.[major_id]
       LEFT JOIN [?].sys.database_principals imp		ON  imp.[principal_id] = perm.[major_id]

WHERE  princ.[type] IN (''U'', ''S'', ''G'')
	   AND princ.[name] NOT IN (''sys'', ''INFORMATION_SCHEMA'')
	   AND NOT ulogin.name IS NULL
'

EXECUTE master.sys.sp_MSforeachdb  @ssql


	
	Set @Return = 1
END TRY

BEGIN CATCH
	--ROLLBACK TRANSACTION
	Set @Return = 0
END CATCH

COMMIT TRANSACTION
RETURN @Return

GO
