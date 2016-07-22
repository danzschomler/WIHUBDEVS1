SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_CollectDatabaseInfo] As

Declare @Return bit; Set @Return = 0


BEGIN TRY
BEGIN TRANSACTION

	declare
		@SrvrNm			varchar(40),
		@Db				varchar(40),
		@Owner			varchar(255),
		@CreateDt 			datetime,
    		@sqlstmt			nvarchar(1000),
		@parmdef			nvarchar(1000),
		@rtn_mode			sql_variant,
		@RecMode			varchar(20),
		@Collatn			varchar(255),		
		@DbStatusFl			int,
		@DbStatus			varchar(20),
		@LastBackupType		varchar(15),
		@LastBackupDt		datetime,
		@LastLogBackupDt		datetime,
		@EntryDt			datetime



	--declare cs_d cursor for 
		--select name, 
		--	 crdate 
		--from master.dbo.sysdatabases

	declare cs_d cursor for 
		SELECT name 
			, create_date as crdate
			--, state_desc as Database_Status
		FROM master.sys.databases 
			Where state_desc = 'ONLINE'

	open cs_d
		fetch next from cs_d into @Db, @CreateDt
		while @@fetch_status = 0
		begin
		
			--- get database mode ---
				set  @sqlstmt =  N'SELECT @rtn_mode =DATABASEPROPERTYEX('''+ rtrim(@Db) + ''', ''recovery'')'
				set  @parmdef=N'@rtn_mode sql_variant OUTPUT'
				exec  master.dbo.sp_executesql @sqlstmt, @parmdef, @rtn_mode = @rtn_mode OUTPUT
				set  @RecMode = cast(@rtn_mode as varchar)

			--- get database collation ---
				set  @sqlstmt =  N'SELECT @rtn_mode =DATABASEPROPERTYEX('''+ rtrim(@Db) + ''', ''Collation'')'
				set  @parmdef=N'@rtn_mode sql_variant OUTPUT'
				exec  master.dbo.sp_executesql @sqlstmt, @parmdef, @rtn_mode = @rtn_mode OUTPUT
				set  @Collatn = cast(@rtn_mode as varchar)

				set @DbStatus = 'OPEN'
			--- get database status ---
			--- first check for dbo only ---
				set  @DbStatusFl = 0
				set  @sqlstmt =  N'SELECT @DbStatusFl = DATABASEPROPERTY('''+ rtrim(@Db) + ''', ''IsDBOOnly'')'
				set  @parmdef=N'@DbStatusFl int OUTPUT'
				exec  master.dbo.sp_executesql @sqlstmt, @parmdef, @DbStatusFl = @DbStatusFl OUTPUT
				IF @DbStatusFl = 1
					set  @DbStatus = 'DBO ONLY'

			--- second check for offline ---
				IF @DbStatusFl = 0
				begin
					set  @sqlstmt =  N'SELECT @DbStatusFl = DATABASEPROPERTY('''+ rtrim(@Db) + ''', ''IsOffline'')'
					set  @parmdef=N'@DbStatusFl int OUTPUT'
					exec  master.dbo.sp_executesql @sqlstmt, @parmdef, @DbStatusFl = @DbStatusFl OUTPUT
					IF @DbStatusFl = 1
						set  @DbStatus = 'OFFLINE'
				end 	
			--- end of check for offline ---

			--- third check for suspect ---
				IF @DbStatusFl = 0
				begin
					set  @sqlstmt =  N'SELECT @DbStatusFl = DATABASEPROPERTY('''+ rtrim(@Db) + ''', ''IsSuspect'')'
					set  @parmdef=N'@DbStatusFl int OUTPUT'
					exec  master.dbo.sp_executesql @sqlstmt, @parmdef, @DbStatusFl = @DbStatusFl OUTPUT
					IF @DbStatusFl = 1
						set  @DbStatus = 'SUSPECT'
				end 
			--- end of check for suspect ---

			--- fourth check for read only ---
				IF @DbStatusFl = 0
				begin
					set  @sqlstmt =  N'SELECT @DbStatusFl = DATABASEPROPERTY('''+ rtrim(@Db) + ''', ''IsReadOnly'')'
					set  @parmdef=N'@DbStatusFl int OUTPUT'
					exec  master.dbo.sp_executesql @sqlstmt, @parmdef, @DbStatusFl = @DbStatusFl OUTPUT
					IF @DbStatusFl = 1
						set  @DbStatus = 'READ ONLY'
				end 
			--- end of check for read only ---

			--- fifth check for standby ---
				IF @DbStatusFl = 0
				begin
					set  @sqlstmt =  N'SELECT @DbStatusFl = DATABASEPROPERTY('''+ rtrim(@Db) + ''', ''IsInStandBy'')'
					set  @parmdef=N'@DbStatusFl int OUTPUT'
					exec  master.dbo.sp_executesql @sqlstmt, @parmdef, @DbStatusFl = @DbStatusFl OUTPUT
					IF @DbStatusFl = 1
						set  @DbStatus = 'STANDBY'
				end 
			--- end of check for standby ---

			--- get database owner ---
				set @Owner = 'UNKNOWN'
				IF @DbStatus not in ('SUSPECT', 'OFFLINE')
				begin
					set @Owner=null
					set @sqlstmt = N'select @Owner = UPPER(l.name) from ['+ rtrim(@Db)+
 								 N'].dbo.sysusers u, master..syslogins l ' +
							   N' where u.name =''dbo'' and u.uid=1 and u.sid = l.sid'
 					set  @parmdef = N'@Owner varchar(255) OUTPUT'
					exec  master.dbo.sp_executesql @sqlstmt, @parmdef, @Owner = @Owner OUTPUT
				end
			--- end of get database owner ---

			--- get database backup information ---
				--- D = Database.   
				--- I = Database Differential. 
        			--- L = Log.
				--- F = File or Filegroup.

			set @LastBackupType = 'NONE'
			set @LastBackupDt	= NULL
			set @LastLogBackupDt = NULL
        		select @LastBackupType = case b.type when 'D' then 'FULL' 
									 when 'I' then 'INCREMENTAL' 
							    		 else 'UNKNOWN' 
							    		 end, 
				   @LastBackupDt = max(b.backup_finish_date) 
        		from msdb.dbo.backupset b 
        		where b.type in ('D', 'I') 
        		and b.database_name = @Db
        		group by b.type 

	  		if @RecMode = 'FULL'
				select  @LastLogBackupDt = max(b.backup_finish_date) 
				from msdb.dbo.backupset b 
				where b.type = 'L' 
				and b.database_name = @Db


		--- insert into localDbInfo table ---
			insert into localDatabaseInfo
				(DatabaseName,
      			 DatabaseOwner,
      			 CreateDate,
				 RecoveryMode,
				 Coallition,
				 DatabaseStatus,
				 LastBackupType,
				 LastBackupDate,
				 LastLogBackupDate,
				 CaptureDate)
			values 
				(
				 @Db,
      			 @Owner,
      			 @CreateDt,
				 @RecMode,
				 @Collatn,
				 @DbStatus,
				 @LastBackupType,
				 @LastBackupDt,
				 @LastLogBackupDt,
				 GetDate())

			fetch next from cs_d into @Db, @CreateDt
		end
		close cs_d
		deallocate cs_d

		--UPDATE Always On Role as appropriate
		IF SERVERPROPERTY('ProductVersion') >= '11'
		BEGIN
			UPDATE db 
				SET db.AlwaysOnRole = hope.role_desc
			FROM dbo.localDatabaseInfo AS db
			INNER JOIN 
				(SELECT name, role_desc
				FROM sys.DATABASES d
				INNER JOIN sys.dm_hadr_availability_replica_states hars ON d.replica_id = hars.replica_id) AS hope
			ON db.DatabaseName = hope.name
		END

	Set @Return = 1
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	Print ERROR_MESSAGE()
	Set @Return = 0
END CATCH

COMMIT TRANSACTION
RETURN @Return

GO
