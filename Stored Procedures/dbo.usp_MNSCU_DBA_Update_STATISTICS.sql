SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[usp_MNSCU_DBA_Update_STATISTICS] 
	  @timeLimit INT = 30										/* job execution time limit in minutes */
	, @printCMD BIT = 0											/* used for debugging.  If true, will print the message in the debug window */
	, @executeSQL BIT = 1										/* used for debugging.  If false, will skip selected execute_sql statements */
	, @mailrecipients NVARCHAR(500)								/* Who to send error message to, as needed */
	, @SystemDB BIT = 1											/* Include system databases?  Default True*/

AS/*
	
	Name:  usp_MNSCU_DBA_Update_STATISTICS

	Author:  Dan Zschomler

	Purpose:  To replace built in SQL Maintenance Plan statistic update that do not that tod not always recognize when an Always on Availability Group switches.  
			  This proc designed to handle ALL database on a server utilizing AlwaysOn.  

	Notes:    

	----------------------------------------------------------------------------
    DISCLAIMER: 
    This code and information are provided "AS IS" without warranty of any kind,
    either expressed or implied, including but not limited to the implied 
    warranties or merchantability and/or fitness for a particular purpose.
    ----------------------------------------------------------------------------
    Date        Initials	Version Description
    ----------------------------------------------------------------------------
	2016-07-08	DMZ			1.0		Inital Release
	*********************************************************************************
    Example of how to call this script:

		EXEC dbo.usp_MNSCU_DBA_Update_STATISTICS
			@@timeLimit = 30
			, @executeSQL = 1
			, @printCMD = 0
			, @mailrecipients = 'recipients@domain.com'
			, @SystemDB = 1
		]
	*****************************************************************************/		

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;

	/*Validate parameters */
	IF @timeLimit IS NULL or @timeLimit = 0
		Set @timeLimit = 30													/* If time limit not provided, default to 30 minute limit */
	IF @mailrecipients IS NULL OR @mailrecipients = ''
		SET @mailrecipients = 'sqlserver-info@sinope.mnscu.edu'

DECLARE @Counter DECIMAL(18,0)
DECLARE @databasename VARCHAR(255)
DECLARE @tablename VARCHAR(255)
DECLARE @Statsname VARCHAR(255)
DECLARE @ssql NVARCHAR(1000)
DECLARE @starttime datetime
DECLARE @endtime DATETIME
DECLARE @subjectline NVARCHAR(50)
DECLARE @bodyline NVARCHAR(500)
DECLARE @datetimeSTART DATETIME
DECLARE @datetimeEND DATETIME


/* Create our temporary table */
CREATE TABLE #databaseList
(
      databaseID        INT
    , databaseName      VARCHAR(128)
   
);

/**Define list of databases to update.  Exclude read only, Online only, and Primary Always On Group, if Always On applies */
IF  LEFT(CAST(SERVERPROPERTY('ProductVersion') as VARCHAR(20)),2) >= 11
	SET @ssql = 'INSERT INTO #databaseList ' +
		' Select d. database_id, d.name FROM sys.databases d '+
			' LEFT JOIN sys.dm_hadr_availability_replica_states hars ON d.replica_id = hars.replica_id ' +
		' Where  d.[state] = 0  AND d.is_read_only = 0 and (hars.role_desc = ''PRIMARY'' or hars.role_desc Is NULL)'
ELSE
	SET @ssql = 'INSERT INTO #databaseList ' +
		' Select d. database_id, d.name FROM sys.databases d '  + 
		' Where  d.[state] = 0  AND d.is_read_only = 0'

	IF @SystemDB = 1 
		SET @ssql = @SSql + ' AND d.database_ID <> 2'
	ELSE
		SET @ssql = @ssql + ' AND d.database_ID > 4'
	
	IF @printCMD = 1 PRINT @ssql
	IF @executeSQL = 1 EXECUTE sp_executesql @ssql	


/* Populate list of statistics to be updated */
TRUNCATE TABLE dba_statsList

DECLARE csList CURSOR FOR
	SELECT databaseName FROM #databaseList 
	
OPEN csList
FETCH NEXT FROM csList INTO @databasename

WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @ssql = 'USE [' +  @databasename + '] INSERT INTO DBA_Maint.dbo.dba_statsList ' +
				'( databaseName ,' +
					'TableName ,' +
					'StatsName' +
						')		' +
				'SELECT DISTINCT ' +	
					'DB_NAME(DB_ID()) , ' +
					'OBJECT_NAME(s.[object_id]), ' +
					's.name AS StatName ' +
					'FROM sys.stats s ' +
					'JOIN sys.stats_columns sc ON sc.[object_id] = s.[object_id] AND sc.stats_id = s.stats_id ' +
					'JOIN sys.columns c ON c.[object_id] = sc.[object_id] AND c.column_id = sc.column_id ' +
					'JOIN INFORMATION_SCHEMA.COLUMNS D ON D.[COLUMN_NAME]= C.[NAME] ' +
					'JOIN sys.partitions par ON par.[object_id] = s.[object_id] ' +
					'JOIN sys.objects obj ON par.[object_id] = obj.[object_id] ' +
					'WHERE OBJECTPROPERTY(s.OBJECT_ID,''IsUserTable'') = 1 ' +
					'AND D.DATA_TYPE NOT IN(''NTEXT'',''IMAGE'')'

		IF @printCMD = 1 PRINT @ssql
		IF @executeSQL = 1 EXECUTE sp_executesql @ssql

	FETCH NEXT FROM csList INTO @databasename
	END

CLOSE csList
DEALLOCATE csList
	
/* Caclulate the maximum time to run, code in the cursor will break execution if when the current time exceeds this value */
SELECT @starttime = GETDATE(), @endtime = DATEADD(minute, @timeLimit, GETDATE())
SET @subjectline = 'usp_MNSCU_DBA_Update_STATISTICS error on ' + @@SERVERNAME  
SET @bodyline = 'usp_MNSCU_DBA_Update_STATISTICS error on ' + @@SERVERNAME + ' exceeded alotted time limit of ' + CONVERT(NVARCHAR(3), @timeLimit) + ' minutes.'

DECLARE csSTATS CURSOR FOR
	SELECT [Counter], databasename, tablename, statsname FROM dba_statsList
	
OPEN csSTATS
FETCH NEXT FROM csSTATS INTO @Counter, @databasename, @tablename, @Statsname

WHILE @@FETCH_STATUS = 0
	BEGIN
		
		If GetDate() >= @endtime 
			BEGIN
				EXEC msdb.dbo.sp_send_dbmail 
					@profile_name = 'mailhost'
				    , @recipients = @mailrecipients
				    , @subject = @subjectline
				    , @body = @bodyline
				BREAK
			END

		SET @datetimeSTART = GETDATE()
		SET @ssql = 'USE [' +  @databasename + '] UPDATE STATISTICS ' +  @tablename + ' ' + @Statsname + ' WITH FULLSCAN'
		        
		IF @printCMD = 1 PRINT @ssql
		IF @executeSQL = 1 EXECUTE sp_executesql @ssql
		SET @datetimeEND = GETDATE()

		UPDATE dbo.dba_statsList
			SET datetimeStart = @datetimeSTART
				, datetimeEnd = @datetimeEND
				, durationSeconds = DATEDIFF(SECOND,@datetimestart,@datetimeEnd)
				, SQLStatement = @ssql 
			WHERE Counter = @Counter

	FETCH NEXT FROM csSTATS INTO @Counter, @databasename, @tablename, @Statsname
	END

CLOSE csSTATS
DEALLOCATE csSTATS


IF OBJECT_ID('tempdb.#DatabaseList') IS NOT NULL DROP TABLE #databaseList 
GO
