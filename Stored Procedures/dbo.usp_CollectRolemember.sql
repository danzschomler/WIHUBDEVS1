SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_CollectRolemember] As

Declare @Return bit; Set @Return = 0
Declare @DbName nvarchar(255)
Declare @ssql nvarchar(4000)
Declare @RoleName nvarchar(255)
--BEGIN TRANSACTION
BEGIN TRY

	Create Table #TmpTable(
		RoleName  nvarchar(50),
		RoleID  integer,
		ISAppRole  integer)
	
	--Delete from DBA.dbo.localRolemember 

	declare cs_r cursor for
		Select name from master.dbo.sysdatabases 
	
	open cs_r
		fetch next from cs_r into @DbName
		while @@fetch_status = 0
		begin
	
		Set @ssql = 'EXEC ['+ @DbName + '].dbo.sp_helprole'
		--Print @ssql
		INSERT INTO #TmpTable EXEC sp_executesql @ssql
	
		--Set @ssql = 'EXEC [' + @DbName + '].dbo.sp_helprole'
		declare cs_r_role cursor for 
			Select RoleName from #TmpTable where RoleName <> 'webreport_approle'
			Open cs_r_role
			fetch next from cs_r_role into @RoleName
			While @@fetch_status = 0
			begin
		
				set @ssql = 'INSERT INTO dbo.localRolemember (RoleName, UserName, UserID) EXEC [' + @DbName + '].dbo.sp_helprolemember '''+ @RoleName + ''''
				--Print @ssql
				EXEC sp_executesql @ssql
				Update dbo.localRolemember Set DatabaseName = @DbName, CaptureDate  = GetDate() where DatabaseName is null
		
			fetch next from cs_r_role into @RoleName
			End
			close cs_r_role
			deallocate cs_r_role
	
			Delete from #TmpTable

	
		fetch next from cs_r into @DbName
		end

		close cs_r
		deallocate cs_r

		Drop Table #TmpTable

	Set @Return = 1

END TRY

BEGIN CATCH
	--ROLLBACK TRANSACTION
	PRINT ERROR_MESSAGE()
	Set @Return = 0
END CATCH

--COMMIT TRANSACTION

RETURN @Return

GO
