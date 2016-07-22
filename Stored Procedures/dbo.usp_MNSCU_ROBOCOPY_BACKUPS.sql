SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_MNSCU_ROBOCOPY_BACKUPS]

/*DECLARE PARAMETERS*/
	  @RoboCopySource NVARCHAR(500)			/* Source directory of all databases backups*/
	, @RoboCopyDestination NVARCHAR(500)	/* Destination directory/share for all datatbase backups*/
	, @timeLimit INT = 120					/* job execution time limit in minutes */
	, @executeSQL BIT = 1					/* Used for debugging.  If value false, some actions won't occur.  Default: True*/
	, @printCMD BIT = 0						/* Used for debugging.  If set to true, will print out commands to debug Window.  Default: False  */
AS /*
Name:  usp_MNSCU_ROBOCOPY_BACKUPS

	Author:  Dan Zschomler

	Purpose:  To copy backups for MIRRORED or ALWAYSON Availability Group databases from the 'Active' environment to the 'Secondary'
				In case there were ever an unscheduled failover and we needed recent backups for point in time recovery

	Notes:    

	----------------------------------------------------------------------------
    DISCLAIMER: 
    This code and information are provided "AS IS" without warranty of any kind,
    either expressed or implied, including but not limited to the implied 
    warranties or merchantability and/or fitness for a particular purpose.
    ----------------------------------------------------------------------------
    Date        Initials	Version Description
    ----------------------------------------------------------------------------
	2016-07-05	DMZ			1.0		Inital Release
	*********************************************************************************
    Example of how to call this script:

		EXEC dbo.usp_MNSCU_ROBOCOPY_BACKUPS
			  @RoboCopySource = 'W:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup'
			, @RoboCopyDestination = '\\EIHUBDEVS1\AGBackups\'
			, @timeLimit = 120
		[
			, @executeSQL = 1
			, @printCMD = 0
		]
	*****************************************************************************/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;

	BEGIN TRY 

		/*Local Paramaters*/
		DECLARE @DatabaseName NVARCHAR(100)			/*Database Name*/
		DECLARE @sqlcmd NVARCHAR(1000)
		DECLARE @IPGSpeed NVARCHAR(5)			
		DECLARE @timeLimitEnd DATETIME 			
		DECLARE @datetimeSTART DATETIME
		DECLARE @cmdshellEnabled BIT					/*Was xp_cmdshell enabled on the server prior to starting?*/
		DECLARE @ErrorMessage   NVARCHAR(2000)
		DECLARE @ErrorSeverity  tinyint
		DECLARE @ErrorState     tinyint
	
	
		/*Validate parameters */
		IF @timeLimit IS NULL or @timeLimit = 0
			Set @timeLimit = 60	

		--If @RoboCopySource not defined or not accessible - throw error
		CREATE TABLE #temp (FileExists int, IsDirectory int, ParentDirExists int)
		INSERT INTO #temp
		EXEC master..xp_fileexist @RoboCopySource
		IF NOT EXISTS(SELECT IsDirectory FROM #temp WHERE IsDirectory=1) 
			RAISERROR('SOURCE DIRECTORY DOES NOT EXISTS',16,1)
		DROP TABLE #temp

		--IF @RoboCopyDestination not defined or not accessible - throw error
		CREATE TABLE #temptable (FileExists int, IsDirectory int, ParentDirExists int)
		INSERT INTO #temptable
		EXEC master..xp_fileexist @RoboCopyDestination
		IF NOT EXISTS(SELECT IsDirectory FROM #temptable WHERE IsDirectory=1) 
			RAISERROR('DESTINATION DIRECTORY DOES NOT EXISTS',16,1)
		DROP TABLE #temptable

	/*If table dba_RoboCopyDatabases does not exist, create it.*/
	if not exists (select * from sysobjects where name='dba_RoboCopyDatabases' and xtype='U')
		BEGIN
			CREATE TABLE [dbo].[dba_RoboCopyDatabases](
			[Counter] [DECIMAL](18, 0) IDENTITY(1,1) NOT NULL,
			[DatabaseName] [NVARCHAR](100) NULL,
			[IPGSpeed] [NVARCHAR](5) NULL,
			[CreateDate] [DATETIME] NULL,
		 CONSTRAINT [PK_dba_RoboCopyDatabases] PRIMARY KEY CLUSTERED 
		(
			[Counter] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]
		END

	/*Insert unmatched MIRROR databases into RoboCopyDatabases*/
	INSERT INTO DBA_Maint.dbo.dba_RoboCopyDatabases(DatabaseName,IPGSpeed, CreateDate)
	SELECT d.name, '750', GETDATE()
	FROM sys.databases d
		JOIN sys.database_mirroring dm ON d.database_id = dm.database_id
		WHERE dm.mirroring_state = 4 AND mirroring_role = 1 
		AND d.Name NOT IN (SELECT DatabaseName FROM DBA_Maint.dbo.dba_RoboCopyDatabases)

	/*Insert unmatched Availability group databases into RoboCopyDatabases*/
	IF  LEFT(CAST(SERVERPROPERTY('ProductVersion') as VARCHAR(20)),2) >= 11
		INSERT INTO DBA_Maint.dbo.dba_RoboCopyDatabases(DatabaseName,IPGSpeed, CreateDate)
			SELECT d.name, '750', GETDATE()
				 FROM sys.databases d 
				LEFT JOIN sys.dm_hadr_availability_replica_states hars ON d.replica_id = hars.replica_id 
				WHERE hars.role_desc = 'Primary'
				AND d.Name NOT IN (SELECT DatabaseName FROM DBA_Maint.dbo.dba_RoboCopyDatabases)

	/*Delete databases defined in RoboCopyDatabases no longer MIRRORed*/
	DELETE FROM DBA_Maint.dbo.dba_RoboCopyDatabases
		WHERE DatabaseName IN (
				SELECT rcd.DatabaseName 
					FROM DBA_Maint.dbo.dba_RoboCopyDatabases rcd
							WHERE NOT EXISTS (SELECT d.name 
											FROM sys.databases d
												JOIN sys.database_mirroring dm ON d.database_id = dm.database_id
											WHERE d.NAME = rcd.DatabaseName))

	/*Delete databases defined in RoboCopyDatabases no longer in Availability Group*/
	DELETE FROM DBA_Maint.dbo.dba_RoboCopyDatabases
		WHERE DatabaseName IN (
				SELECT rcd.DatabaseName
					FROM DBA_Maint.dbo.dba_RoboCopyDatabases rcd
					WHERE NOT EXISTS (SELECT d.name 
										FROM sys.databases d 
											LEFT JOIN sys.dm_hadr_availability_replica_states hars ON d.replica_id = hars.replica_id 
										WHERE d.name = rcd.DatabaseName))

	/*IF xp_cmdshell not enabled, enable it*/
	SELECT @cmdshellEnabled =  CONVERT(INT, ISNULL(value, value_in_use)) FROM  sys.configurations WHERE name = 'xp_cmdshell' ;

	IF @cmdshellEnabled = 0
		BEGIN
			EXEC master.dbo.sp_configure 'show advanced options', 1
			RECONFIGURE WITH OVERRIDE			
			EXEC master.dbo.sp_configure 'xp_cmdshell', 1
			RECONFIGURE WITH OVERRIDE
		END

	/* Loop through table, build @sqclmd command  */
	SET @timeLimitEnd = DATEADD(minute, @timeLimit, GETDATE())

	DECLARE db_cursor CURSOR FOR	
	SELECT DatabaseName, IPGSpeed FROM DBA_Maint.dbo.dba_RoboCopyDatabases

	OPEN db_cursor

		FETCH NEXT FROM db_cursor INTO @DatabaseName, @IPGSPeed
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @sqlcmd= 'robocopy "' + @RoboCopySource +'\' + @DatabaseName + '" "'+ @RoboCopyDestination +  '\' + @DatabaseName + '" /e /maxage:1 /xo /ipg:' + @IPGSpeed
			SET @datetimeSTART = GETDATE()

			IF @printCMD = 1 PRINT @sqlcmd
			--IF @executeSQL = 1 EXECUTE sp_executesql @sqlcmd
			IF @executeSQL = 1 EXEC master.dbo.xp_cmdshell @sqlcmd   --????

			INSERT INTO dbo.dba_backupexecutionhistory(SQLCommand, datetimeStart, datetimeEnd, durationSeconds)
				VALUES (@sqlcmd, @datetimeSTART, GETDATE(), DATEDIFF(SECOND, @datetimeSTART,GETDATE()))

			IF GETDATE() >= @timeLimitEnd 
				RAISERROR('EXECUTION TIME LIMIT REACHED',16,1)

			FETCH NEXT FROM db_cursor INTO @DatabaseName, @IPGSpeed
		END

	CLOSE db_cursor
	DEALLOCATE db_cursor
	IF @printCMD = 1 PRINT 'END CURSOR'			
	
		/*If xp_cmdshell was disabled, re-disabled it */
		IF @cmdshellEnabled = 0
			BEGIN
			EXEC master.dbo.sp_configure 'show advanced options', 1
			RECONFIGURE WITH OVERRIDE			
			EXEC master.dbo.sp_configure 'xp_cmdshell', 0
			RECONFIGURE WITH OVERRIDE
			END
																						
	END TRY

	

	BEGIN CATCH 

		/*If xp_cmdshell was disabled, re-disabled it */
		IF @cmdshellEnabled = 0
			BEGIN
			EXEC master.dbo.sp_configure 'show advanced options', 1
			RECONFIGURE WITH OVERRIDE			
			EXEC master.dbo.sp_configure 'xp_cmdshell', 0
			RECONFIGURE WITH OVERRIDE
			END

			SET @ErrorMessage  = ERROR_MESSAGE()
			SET @ErrorSeverity = ERROR_SEVERITY()
			SET @ErrorState    = ERROR_STATE()
			RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

			

	END CATCH
GO
