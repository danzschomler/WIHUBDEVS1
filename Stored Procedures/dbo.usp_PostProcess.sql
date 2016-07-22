SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  Procedure [dbo].[usp_PostProcess] as 
Declare @Return bit
Set @Return = 0

BEGIN TRY
	EXEC usp_UpdateServerName
	--EXEC usp_MigrateBackupToLocation
	

	Set @Return = 1

END TRY

BEGIN CATCH
	PRINT ERROR_MESSAGE()
	Set @Return = 0
END CATCH
 
RETURN @Return


GO
