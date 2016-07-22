SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_CollectOrphanUsers] AS
Declare @Return bit; Set @Return = 0
Declare @hope nvarchar(1000)

BEGIN TRANSACTION

	BEGIN TRY

		Set @hope = 'if ''?'' Not In  (''master'',''tempdb'',''model'',''msdb'',''distrobution'') ' +
			'Insert Into DBA_Maint.dbo.localOrphanUsers(DatabaseName, Orphan_User, CreateDate, Action_Task, CaptureDate) ' +
			'SELECT ''?'' as DataBaseName ' + 
			', sysusers.name as Orphane_User ' + 
			', sysusers.createdate ' +
			',  CASE WHEN sysusers.name = syslogins.name COLLATE SQL_Latin1_General_CP1_CS_AS THEN ''Repair'' ' +
			'   WHEN UPPER(sysusers.name) = UPPER(syslogins.name) COLLATE database_default THEN ''Check_Case'' ' +
			'   ELSE ''Add_or_Delete'' END as Action_Task   ' +
			', GetDate() ' +
		'From [?].dbo.sysusers   ' +
		'Left Join master.dbo.syslogins  ' +
		'on UPPER(sysusers.name) = UPPER(syslogins.name) COLLATE database_default ' +
		'WHERE issqluser = 1   ' +
			'and (sysusers.sid is not null and sysusers.sid <> 0x0) ' +
			'and sysusers.sid not in  ' +
			'	(Select sid from master.dbo.syslogins)  '


		Exec master.dbo.sp_MSforeachdb @hope

		Set @Return = 1
	END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	Set @Return = 0
END CATCH

COMMIT TRANSACTION
RETURN @Return

GO
