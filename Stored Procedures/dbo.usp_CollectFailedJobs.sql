SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  Procedure [dbo].[usp_CollectFailedJobs] as
Declare @Return bit
Set @Return = 0

BEGIN TRANSACTION

BEGIN TRY

DECLARE @PreviousDate datetime
DECLARE @Year VARCHAR(4)
DECLARE @Month VARCHAR(2)
DECLARE @MonthPre VARCHAR(2)
DECLARE @Day VARCHAR(2)
DECLARE @DayPre VARCHAR(2)
DECLARE @FinalDate INT

-- Initialize Variables
SET @PreviousDate = DATEADD(dd, -1, GETDATE()) 
SET @Year = DATEPART(yyyy, @PreviousDate) 
SELECT @MonthPre = CONVERT(VARCHAR(2), DATEPART(mm, @PreviousDate))
SELECT @Month = RIGHT(CONVERT(VARCHAR, (@MonthPre + 1000000000)),2)
SELECT @DayPre = CONVERT(VARCHAR(2), DATEPART(dd, @PreviousDate))
SELECT @Day = RIGHT(CONVERT(VARCHAR, (@DayPre + 1000000000)),2) 
SET @FinalDate = CAST(@Year + @Month + @Day AS INT) 

		INSERT INTO dbo.localFailedJobs(
			JobName
			, StepName
			, SQLSeverity
			, [Message]
			, RunDate
			, RunTime
			, CaptureDate)

		SELECT j.name
			,js.step_name
			,jh.sql_severity
			,SubString(jh.message,1,999)
			,jh.run_date
			,jh.run_time
			--,jh.server 
			,GETDATE() AS CaptureDate
		FROM msdb.dbo.sysjobs AS j
		INNER JOIN msdb.dbo.sysjobsteps AS js ON js.job_id = j.job_id
		INNER JOIN msdb.dbo.sysjobhistory AS jh ON jh.job_id = j.job_id 
		WHERE jh.run_status = 0
		AND jh.run_date > @FinalDate

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
