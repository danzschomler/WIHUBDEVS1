SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_CollectLinkedServers] AS
Declare @Return bit; Set @Return = 0

BEGIN TRANSACTION

BEGIN TRY

	Declare  @Link Table (LinkServer nvarchar(255), LocalLogin nvarchar(50), IsSelfMapping bit, RemoteLogin nvarchar(50))

	Insert Into @Link
	exec master.dbo.sp_helplinkedsrvlogin

	Insert Into dbo.localLinkedServer(LinkServer,LocalLogin, IsSelfMapping,RemoteLogin, CaptureDate )
	Select LinkServer, LocalLogin,IsSelfMapping, RemoteLogin, GetDate() from @Link
	where LinkServer <> @@serverName 

	Set @Return = 1

END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	Set @Return = 0
END CATCH

COMMIT TRANSACTION
RETURN @Return

GO
