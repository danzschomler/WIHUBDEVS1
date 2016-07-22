SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  Procedure [dbo].[usp_CollectAgentData] as
Declare @Return bit
Set @Return = 0

BEGIN TRANSACTION

BEGIN TRY

	INSERT INTO [dbo].[localAgentJobs]
			   ([JobName]
			   ,[JobOwner]
			   ,[JobCategory]
			   ,[JobDescription]
			   ,[IsEnabled]
			   ,[JobCreatedOn]
			   ,[JobLastModifiedOn]
			   ,[OriginatingServerName]
			   ,[IsScheduled]
			   ,[JobScheduleName]
			   ,[CaptureDate])
	SELECT 
		 [sJOB].[name] AS [JobName]
		, [sDBP].[name] AS [JobOwner]
		, [sCAT].[name] AS [JobCategory]
		, Left([sJOB].[description],255) AS [JobDescription]
		, CASE [sJOB].[enabled]
			WHEN 1 THEN 'Yes'
			WHEN 0 THEN 'No'
		  END AS [IsEnabled]
		, [sJOB].[date_created] AS [JobCreatedOn]
		, [sJOB].[date_modified] AS [JobLastModifiedOn]
		, [sSVR].[name] AS [OriginatingServerName]
		, CASE
			WHEN [sSCH].[schedule_uid] IS NULL THEN 'No'
			ELSE 'Yes'
		  END AS [IsScheduled]
		, [sSCH].[name] AS [JobScheduleName]
		,GetDate() as [CaptureDate]
	FROM
		[msdb].[dbo].[sysjobs] AS [sJOB]
		LEFT JOIN [msdb].[sys].[servers] AS [sSVR]
			ON [sJOB].[originating_server_id] = [sSVR].[server_id]
		LEFT JOIN [msdb].[dbo].[syscategories] AS [sCAT]
			ON [sJOB].[category_id] = [sCAT].[category_id]
		LEFT JOIN [msdb].[dbo].[sysjobsteps] AS [sJSTP]
			ON [sJOB].[job_id] = [sJSTP].[job_id]
			AND [sJOB].[start_step_id] = [sJSTP].[step_id]
		LEFT JOIN [msdb].[sys].[database_principals] AS [sDBP]
			ON [sJOB].[owner_sid] = [sDBP].[sid]
		LEFT JOIN [msdb].[dbo].[sysjobschedules] AS [sJOBSCH]
			ON [sJOB].[job_id] = [sJOBSCH].[job_id]
		LEFT JOIN [msdb].[dbo].[sysschedules] AS [sSCH]
			ON [sJOBSCH].[schedule_id] = [sSCH].[schedule_id]
	Order by 1,3

	Set @Return = 1

	COMMIT TRANSACTION

END TRY

BEGIN CATCH
	PRINT ERROR_MESSAGE()
	ROLLBACK TRANSACTION
	Set @Return = 0
END CATCH
 
RETURN @Return

GO
