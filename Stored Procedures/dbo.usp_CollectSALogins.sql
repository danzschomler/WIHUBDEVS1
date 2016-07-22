SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_CollectSALogins] AS
Declare @Return bit
Set @Return = 0

BEGIN TRY
BEGIN TRANSACTION
	Insert Into dbo.localSALogins(loginname,CaptureDate)

		select ss.loginname, GetDate()
	from sys.syslogins ss inner join
	sys.server_principals sp
	on ss.sid =sp.sid
	where ss.sysadmin = 1 and sp.is_disabled = 0 and ss.loginname Not Like 'NT SERVICE\%'

	Set @Return = 1

END TRY

BEGIN CATCH
	PRINT ERROR_MESSAGE()
	ROLLBACK TRANSACTION
	Set @Return = 0
END CATCH

COMMIT TRANSACTION

RETURN @Return

GO
