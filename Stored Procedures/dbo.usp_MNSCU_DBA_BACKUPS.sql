
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*   ADDING CODE TO TEST MORE UPDATES INTO GITHUB			7/28/2016 11:46 AM */

CREATE PROCEDURE [dbo].[usp_MNSCU_DBA_BACKUPS]

	/* Declare Parameters */
	  @backupDirectory		NVARCHAR(500)	= ''   				    /* Parent backup target directory - Database subfolders will be created in this directory */
	, @backupSystemDB		bit				= 1						/* Should proc inlcude system databases?  Yes(True) or No(False) ?  Defai;t: Yes/True */
	, @backupType			VARCHAR(5)		= 'FULL'				/* Type of SQL Backup.  Full, Diff, or Log   Default: FULL*/
	, @AGGroupOption		VARCHAR(10)		= 'Secondary'			/* What type of AlawaysOn Group backup should be performed, Primary or Secondary.  Default: Secondary'  */
	, @BUReadOnly			bit				= 1						/* Option to backup read only databases.  Default: True */
	, @executeSQL			bit				= 1						/* Used for debugging.  If value false, some actions won't occur.  Default: True*/
	, @printCMD				bit				= 0						/* Used for debugging.  If set to true, will print out commands to debug Window.  Default: False  */
	

AS  /*
	
	Name:  usp_MNSCU_DBA_Backups

	Author:  Dan Zschomler

	Purpose:  To replace built in SQL Maintenance Plan backups that do not have enough options to handle Primary vs Seconday AlawaysOn Group.  This proc designed to handle ALL database
			  on a server utilizing AlwaysOn.  Not necessarily intended for non-AlwaysOn servers.

	Notes:    FUNCTION dbo.fn_SQLServerBackupDir required for this proc to operate

	----------------------------------------------------------------------------
    DISCLAIMER: 
    This code and information are provided "AS IS" without warranty of any kind,
    either expressed or implied, including but not limited to the implied 
    warranties or merchantability and/or fitness for a particular purpose.
    ----------------------------------------------------------------------------
    Date        Initials	Version Description
    ----------------------------------------------------------------------------
	2016-07-05	DMZ			1.0		Inital Release
	2016-07-12	DMZ			1.1		Remove COPY_ONLY and Add NOINT to each backup command
	*********************************************************************************
    Example of how to call this script:

		EXEC dbo.usp_MNSCU_DBA_BACKUPS
			@backupDirectory = 'W:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup'
		[	@backupSystemDB = 1	
			, @backupType = 'FULL'
			, @AGGroupOption = 'Secondary'
			, @BUReadOnly = 1
			, @executeSQL = 1
			, @printCMD = 0
		]
	*****************************************************************************/																
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;

	/*Validate parameters */
	/* If backup directory not provided, attempt to retrieve the value defined in the registry */
	IF @backupDirectory IS NULL OR @backupDirectory = ''									
		EXEC @backupDirectory = master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',N'Software\Microsoft\MSSQLServer\MSSQLServer',N'BackupDirectory', @backupDirectory OUTPUT		
		
	IF @backupType Not In ('FULL','DIFF','DIFFERENTIAL', 'LOG')			
		Set @backupType = 'FULL'											/* If backup type not defined, default to FULL  */

	IF @backupType = 'DIFFERENTIAL'											/* The word 'DIFFERENTIAL' is to long an begs for spelling errors, if that passed in, change it to simply 'DIFF'  */
		Set @backupType = 'DIFF'

	IF @AGGroupOption Not In ('Primary','Seconday')	
		Set @AGGroupOption = 'Secondary'									/* If Always On Group backup option not specified, default to Secondary.  Applies only to Always On Group environments */

	IF Right(@backupDirectory,1) <> '\'
		Set @backupDirectory = @backupDirectory + '\'						/* If backup directory does not end in a backslash, add one  */

	IF OBJECT_ID (N'dba_backupexecutionhistory', N'U') IS NULL				/* Create history table if does not exist  */
		BEGIN
			CREATE TABLE [dbo].[dba_backupexecutionhistory](
			[Counter] [DECIMAL](18, 0) IDENTITY(1,1) NOT NULL,
			[SQLCommand] [NVARCHAR](MAX) NULL,
			[datetimeStart] [DATETIME] NULL,
			[datetimeEnd] [DATETIME] NULL,
			[durationSeconds] [INT] NULL
		) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

		END

	/* Declare local variables  */
	Declare @sqlcmd NVARCHAR(1000)											/*  Used to construction dynamic backup statement per database   */
	Declare @DatabaseName varchar(100)										/*  Database name (duh)  */
	Declare @RoleDescription varchar(50)									/*  Used in cursor below, placeholder for the type of Always On Group type  */
	Declare @RecoveryMethod nvarchar(50)									/*  Recovery Method of the database */
	Declare @IsAvailReplicaGroup BIT = 0									/*  Is the current server part of an AlwaysOn Availability Group?  Boolean, true or false.  Default: False */
	Declare @FolderName nvarchar(255)										/*  Backup directory */
	Declare @FileName nvarchar(255)											/*  Fully qualified backup file path */
	DECLARE @datetimeStart DATETIME
	DECLARE @datetimeEnd DATETIME

	CREATE TABLE #DatabaseList (DatabaseName NVARCHAR(100), RecoveryMethod NVARCHAR(50), RoleDescription NVARCHAR(50))	/*  List of all databases on this server to backup   */
	/* Create a list of backup subdirectories to compair agaist later.  If paths don't exist compaired to these results, will create it  */
	CREATE TABLE #ResultSet(Directory nvarchar(500))
			INSERT INTO #ResultSet 
			EXEC master.dbo.xp_subdirs @backupDirectory

	/*  If current server is version 2012 or greater, check if any rows exists in sys.availability_replicas other than itself.  
		Have to do it this way as sys.availability_replicas table does not exist in servers less than 2012, code would not compile */

	IF  LEFT(CAST(SERVERPROPERTY('ProductVersion') as VARCHAR(20)),2) >= 11
		If EXISTS(Select replica_server_name FROM sys.availability_replicas WHERE replica_server_name <> @@SERVERNAME)SET @IsAvailReplicaGroup = 1 ELSE SET @IsAvailReplicaGroup = 0
		If @printCMD = 1 Print 'IsAvailReplicaGroup = ' + Cast(@IsAvailReplicaGroup as varchar(1))


	/* Create and loop through CURSOR of list of available databases for backup.  Qualifying databases filtered out depending on parameters
			Allow System Databases or not.  Never backup tempdb, include/exclude others based on paraemter*/

	IF @IsAvailReplicaGroup = 0												/* If this server part of AlwaysOn or version Under 2012 */
		SET @sqlcmd = 'Select d.name, d.recovery_model_desc, NULL as [role_desc] from sys.databases d '
	ELSE
		SET @sqlcmd = 'Select d.name, d.recovery_model_desc, hars.role_desc FROM sys.databases d LEFT JOIN sys.dm_hadr_availability_replica_states hars ON d.replica_id = hars.replica_id '

	SET @sqlcmd = @sqlcmd + 'WHERE d.state_desc = ''' + 'ONLINE' + ''''		/*WONDER IF SHOULD CHANGE THIS TO WHERE d.STATE = 0   */
	
	If @BUReadOnly = 0 Set @sqlcmd = @sqlcmd + 'AND d.is_read_only = 0' --ELSE Set @sqlcmd = @sqlcmd + 'AND d.is_read_only = 1'
		
	IF @backupSystemDB = 1	
		SET @sqlcmd = @sqlcmd + ' AND d.database_ID <> 2'					/* Exclude tempdb  */
	ELSE
		SET @sqlcmd = @sqlcmd + 'AND d.database_ID > 4'						/* Ecluse all system databases */

	IF @IsAvailReplicaGroup = 1
		SET @sqlcmd = @sqlcmd + ' AND hars.role_desc IS NULL or hars.role_desc = ''' + @AGGroupOption + ''''


	/* Opted to put list of available databases in temp table opposed to cursor with dynamic code.  Was not going well.  Dump data into temp table and base cursor on it!  */
	If @printCMD = 1 PRINT 'INSERT INTO #DatabaseList(DatabaseName,RecoveryMethod, RoleDescription) EXEC sp_executesql ' + @sqlcmd
	INSERT INTO #DatabaseList(DatabaseName,RecoveryMethod, RoleDescription) EXEC sp_executesql @sqlcmd

	
	/* Loop through list of databases in #DatabaseList and dynamically construct BACKUP DATABASE command */
	DECLARE db_cursor CURSOR FOR		
	Select DatabaseName, RecoveryMethod, RoleDescription from #DatabaseList 

	OPEN db_cursor

		FETCH NEXT FROM db_cursor INTO @DatabaseName, @RecoveryMethod, @RoleDescription
		WHILE @@FETCH_STATUS = 0
		BEGIN
			Set @sqlcmd = ''				/* Clear out variable */
			If @printCMD = 1 PRINT 'BEGIN CURSOR' + QUOTENAME(@DatabaseName) +  QUOTENAME(@RecoveryMethod)+  QUOTENAME(@backupType)   --  If @RoleDescription usually NULL, Prints empty string
			
			If @backupType = 'FULL'
				BEGIN
					SET @FileName = @backupDirectory + @DatabaseName + '\' + @DatabaseName + '_FULL_' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 112), '/', '') + '_' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 108) , ':', '')  + '.bak'
					SET @sqlcmd = 'BACKUP DATABASE ' + QUOTENAME(@DatabaseName) + ' TO DISK = ''' + @FileName + '''' + ' WITH NOINIT, COMPRESSION ' 
						--IF  LEFT(CAST(SERVERPROPERTY('ProductVersion') as VARCHAR(20)),2) > 11 and @RoleDescription = 'PRIMARY'	Set @sqlcmd = @sqlcmd + ', COPY_ONLY'
				END
			IF @BackupType ='DIFF'
				BEGIN
					SET @FileName = @backupDirectory + @DatabaseName + '\' + @DatabaseName  + '_DIFF_' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 112), '/', '') + '_' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 108) , ':', '')  + '.bak'
					SET @sqlcmd = 'BACKUP DATABASE ' + QUOTENAME(@DatabaseName) + ' TO DISK = ''' + @FileName + '''' + ' WITH  DIFFERENTIAL, NOINIT, COMPRESSION ' 
				END
						
			IF  @BackupType = 'LOG'
				BEGIN
					If @RecoveryMethod = 'FULL' AND @DatabaseName <> 'model'						/* No T-log backups for non Full recovery method databases  */
						BEGIN
							SET @FileName = @backupDirectory + @DatabaseName + '\' + @DatabaseName + '_LOG_' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 112), '/', '') + '_' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 108) , ':', '')  + '.trn'
							SET @sqlcmd = 'BACKUP LOG ' + QUOTENAME(@DatabaseName) + ' TO DISK = ''' + @FileName + '''' + ' WITH NOINIT, COMPRESSION ' 
							--IF  LEFT(CAST(SERVERPROPERTY('ProductVersion') as VARCHAR(20)),2) > 11 and @RoleDescription = 'PRIMARY'	Set @sqlcmd = @sqlcmd + ', COPY_ONLY'
						END
				END		
				
				/* Check if Database Name directory exists or not.  Create if not */
				Set @FolderName = @backupDirectory + @DatabaseName
				IF NOT EXISTS (Select * from #ResultSet Where Directory = @DatabaseName) EXEC master.dbo.xp_create_subdir @FolderName

				
				IF @printCMD = 1 PRINT 'Final Backup command: ' + @sqlcmd
				IF @executeSQL = 1 AND @sqlcmd <> '' 
					BEGIN
						SET @datetimeStart = GETDATE()
						EXEC (@sqlcmd)
						SET @datetimeEnd = GETDATE()
						INSERT INTO dbo.dba_backupexecutionhistory([SQLCommand], datetimeStart, datetimeEnd, durationSeconds) 
						VALUES (@SQLcmd, @datetimeStart, @datetimeEnd, DATEDIFF(SECOND,@datetimeStart,@datetimeEnd))
					END
			
		
		FETCH NEXT FROM db_cursor INTO  @DatabaseName, @RecoveryMethod, @RoleDescription
		END

	CLOSE db_cursor
	DEALLOCATE db_cursor
	If @printCMD = 1 PRINT 'END CURSOR'

	IF OBJECT_ID('tempdb.#DatabaseList') IS NOT NULL DROP TABLE #DatabaseList




			
GO
