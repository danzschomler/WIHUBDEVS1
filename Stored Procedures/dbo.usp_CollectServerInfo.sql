SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_CollectServerInfo] AS
Declare @Return bit
Set @Return = 0

BEGIN TRY

	declare
    	@key NVARCHAR(200),
    	@sqlserver_acct	varchar(200),
    	@agent_acct		varchar(200),
		@parmdef		nvarchar(1000),
		@SrvrNm		varchar(40),
    	@sqlstmt		nvarchar(1000),
		@rtn_mode		sql_variant,
		@EntryDt		datetime,
		@Uptime		int,
		@Processors		int,
		@Memory		int,
		@ProductVersion	nvarchar(50),
		@Platform	nvarchar(50),
		@WindowsVersion	nvarchar(50),
		@Edition nvarchar(50),
		@ServicePatch nvarchar(50),
		@Colltn nvarchar(50), 
		@IPAddress nvarchar(50)

	CREATE table #localMsver				
		(
		indx 			int,
		name 			varchar(255),
		internal_value 	int,
		character_value 	varchar(255)
		)


	-- FIND THE OWNER OF THE SERVICES AND AGENT
	-- GET THE NAME OF THE OWNER OF THE SQLAGENT SERVICES 
	SELECT @key = N'SYSTEM\CurrentControlSet\Services\'
	IF (SERVERPROPERTY('INSTANCENAME') IS NOT NULL)
		SELECT @key = @key + N'SQLAgent$' + CONVERT (sysname, SERVERPROPERTY('INSTANCENAME'))
	ELSE
		  SELECT @key = @key + N'SQLServerAgent'
		  set @sqlstmt = N'EXECUTE master.dbo.xp_regread ''HKEY_LOCAL_MACHINE'', ''' +
                 	   		@key + N''' , ''ObjectName'', ' +
                 	   		N'@startup_account output '

	set @parmdef = '@startup_account varchar(200) output'
	EXEC master.dbo.sp_executesql @sqlstmt, 
						@parmdef, 
						@startup_account= @agent_acct Output

	-- GET THE NAME OF THE OWNER OF THE MSSQLSERVER SERVICES
	SELECT @key = N'SYSTEM\CurrentControlSet\Services\'
	IF (SERVERPROPERTY('INSTANCENAME') IS NOT NULL)
		SELECT @key = @key + N'MSSQL$' + CONVERT (sysname, SERVERPROPERTY('INSTANCENAME'))
	ELSE
		  SELECT @key = @key + N'MSSQLSERVER'
		set @sqlstmt = N'EXECUTE master.dbo.xp_regread ''HKEY_LOCAL_MACHINE'', ''' +
					@key + N''' , ''ObjectName'', ' +
					N'@startup_account output '

	set @parmdef = '@startup_account varchar(200) output'
	EXEC master.dbo.sp_executesql @sqlstmt, 
						@parmdef, 
						@startup_account= @sqlserver_acct Output


	INSERT into #localMsver 
	exec master.dbo.xp_msver

	select @Processors = internal_value from #localMsver where name = 'ProcessorCount'
	select @Memory = internal_value from #localMsver where name = 'PhysicalMemory'
	select @ProductVersion = Cast(SERVERPROPERTY('ProductVersion') as varchar(50))
	Select @Edition = Cast(SERVERPROPERTY('Edition') as varchar(50))
	Select @ServicePatch  = Cast(SERVERPROPERTY('ProductLevel') as varchar(50))
	Select @Colltn = CAST( SERVERPROPERTY( 'Collation' ) as varchar(50))
	SELECT @Uptime = datediff(mi, login_time, getdate()) FROM master..sysprocesses  WHERE spid = 1
	select @Platform = internal_value from #localMsver where name = 'Platform'
	select @WindowsVersion = Character_Value  from #localMsver where name = 'WindowsVersion'
	Select @IPAddress = Local_NET_Address from Sys.DM_EXEC_Connections Where Session_ID = @@SPID


BEGIN TRANSACTION

	INSERT into dbo.localServerInfo
		(
		  ServerName
		, ServerOwner
		, AgentOwner
		, Processors
		, Uptime
		, Memory
		, ServicePatch
		, Edition
		, ProductVersion
		, [Platform]
		, WindowsVersion
		, Collation
		, IPAddress 
		, CaptureDate
		)
	VALUES
		(
		  @@servername
		, @sqlserver_acct
		, @agent_acct
		, @Processors
		, @Uptime
		, @Memory
		, @ServicePatch
		, @Edition
		, @ProductVersion
		, @Platform
		, @WindowsVersion
		, @Colltn
		, @IPAddress 
		, getdate()
		)
	
	Set @Return = 1

END TRY

BEGIN CATCH
	PRINT ERROR_MESSAGE()
	ROLLBACK TRANSACTION
	Set @Return = 0
END CATCH

COMMIT TRANSACTION

Drop Table #localMsver
RETURN @Return

GO
