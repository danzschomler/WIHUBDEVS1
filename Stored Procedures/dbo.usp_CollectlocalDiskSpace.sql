SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_CollectlocalDiskSpace] AS

Declare @Return bit; Set @Return = 0
DECLARE @cmdshellEnabled BIT = 0

BEGIN TRY

	Create Table #psinfo(data  NVARCHAR(100)) 
	Create Table #Drives(
		[Drive] char(1) NOT NULL
		, FreeSpace_GB varchar(25) NOT NULL
		, TotalSpace_GB varchar(25) NOT NULL)

/*IF xp_cmdshell not enabled, enable it*/
	SELECT @cmdshellEnabled =  CONVERT(INT, ISNULL(value, value_in_use)) FROM  sys.configurations WHERE name = 'xp_cmdshell' ;
	IF @cmdshellEnabled = 0
		BEGIN
			EXEC master.dbo.sp_configure 'show advanced options', 1
			RECONFIGURE WITH OVERRIDE			
			EXEC master.dbo.sp_configure 'xp_cmdshell', 1
			RECONFIGURE WITH OVERRIDE
		END

	INSERT INTO #psinfo
	EXEC xp_cmdshell 'Powershell.exe "Get-WMIObject Win32_LogicalDisk -filter "DriveType=3"| Format-Table DeviceID, FreeSpace, Size"'  ;

	DELETE FROM #psinfo WHERE data is null  or data like '%DeviceID%' or data like '%----%';

	update #psinfo set data = REPLACE(data,' ',',');
	Select * from #psinfo 

	Insert Into #Drives([Drive],[FreeSpace_GB],[TotalSpace_GB])
	Select	SubString(data,1,1) as [Drive]
			, replace((left((substring(data,(patindex('%[0-9]%',data)) , len(data))),CHARINDEX(',',(substring(data,(patindex('%[0-9]%',data)) , len(data))))-1)),',','') as [FreeSpace]
			, replace(right((substring(data,(patindex('%[0-9]%',data)) , len(data))),PATINDEX('%,%', (substring(data,(patindex('%[0-9]%',data)) , len(data))))) ,',','') as [Size]
	from #psinfo 

	Insert Into dbo.localDiskSpace(Drive,FreeSpace_GB, TotalSize_GB, CaptureDate)
	SELECT [Drive], convert(dec( 6,2),CONVERT(dec(17,2),FreeSpace_GB )/(1024*1024*1024)) as FreeSpaceGB, convert(dec( 6,2),CONVERT(dec(17,2), TotalSpace_GB  )/(1024*1024*1024)) as SizeGB, GetDate()
	FROM #Drives;


	Update dbo.LocalDiskSpace
	Set  FreeSpace_Percent = (FreeSpace_GB / TotalSize_GB) * 100
	Where FreeSpace_Percent IS NULL

	IF @cmdshellEnabled = 0
			BEGIN
			EXEC master.dbo.sp_configure 'show advanced options', 1
			RECONFIGURE WITH OVERRIDE			
			EXEC master.dbo.sp_configure 'xp_cmdshell', 0
			RECONFIGURE WITH OVERRIDE
			END

	Set @Return = 1

END TRY

BEGIN CATCH
	IF @cmdshellEnabled = 0
			BEGIN
			EXEC master.dbo.sp_configure 'show advanced options', 1
			RECONFIGURE WITH OVERRIDE			
			EXEC master.dbo.sp_configure 'xp_cmdshell', 0
			RECONFIGURE WITH OVERRIDE
			END
	Set @Return = 0
END CATCH

Drop Table #psinfo
Drop Table #Drives 

RETURN @Return
GO
