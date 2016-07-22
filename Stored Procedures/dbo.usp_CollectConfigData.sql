SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_CollectConfigData] AS

Declare @Return bit; Set @Return = 0			--Default return code to false

BEGIN TRANSACTION
	BEGIN TRY
		INSERT  INTO [dbo].[localConfigData]
				( [ConfigurationID] ,
				  [Name] ,
				  [Value] ,
				  [ValueInUse] ,
				  [CaptureDate]
				)
				SELECT  [configuration_id] ,
						[name] ,
						[value] ,
						[value_in_use] ,
						GETDATE()
				FROM    [sys].[configurations];

		Set @RETURN = 1
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		Set @Return = 0
	END CATCH

COMMIT TRANSACTION
RETURN @Return

GO
