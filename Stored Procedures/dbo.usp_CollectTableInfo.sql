SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_CollectTableInfo] AS

SET NOCOUNT ON;

DECLARE @cmdstr nvarchar(1000)
DECLARE @DbName nvarchar(100)
Declare @Return bit; Set @Return = 0

	CREATE TABLE #TempTable 
	 (	  DatabaseName nvarchar(100)
		, [Table_Name] varchar(100)
		, Row_Count int
		, Table_Size varchar(50)
		, Data_Space_Used varchar(50)
		, Index_Space_Used varchar(50)
		, Unused_Space varchar(50)
	 )

	Declare cs_t cursor for
		--Select [name] from master.dbo.sysdatabases where dbid > 4 and version > 0
		Select [name] FROM master.sys.databases Where state_desc = 'ONLINE' and database_id > 4

	open cs_t
		fetch next from cs_t into @DbName
		while @@FETCH_STATUS = 0
		begin

		Set @cmdstr = 'Use [' + @dbName + '] Insert Into #TempTable(Table_Name, Row_Count, Table_Size, Data_Space_Used, Index_Space_Used, Unused_Space) EXEC sp_MSforeachtable ''sp_spaceused ''''?'''''' '
		--PRINT @cmdstr
		EXEC sp_executesql @cmdstr
		Update #TempTable Set DatabaseName = @DbName Where DatabaseName Is Null

		fetch next from cs_t into @DbName
		end

	close cs_t
	deallocate cs_t

BEGIN TRY
	BEGIN TRANSACTION

	Insert Into dbo.localTableInfo( 
		  DatabaseName
		, TableName
		, Row_Count
		, TableSize_MB
		, DataSpaceUsed_MB
		, IndexSpaceUsed_MB
		, UnusedSpace_MB
		, CaptureDate)
	 Select DatabaseName 
		, Table_Name
		, Row_Count	
		, Convert(BIGINT, Replace(Table_Size, ' KB',''))/1024 as TableSize_MB
		, Convert(BIGINT, Replace(Data_Space_Used, ' KB',''))/1024 as DataSpaceUsed_MB
		, Convert(BIGINT, Replace(Index_Space_Used, ' KB',''))/1024 as IndexSpaceUsed_MB
		, Convert(BIGINT, Replace(Unused_Space, ' KB',''))/1024 as UnusedSpace_MB
		, GetDate()
	From #TempTable 

	COMMIT TRANSACTION

	Drop Table #TempTable 
	
	Set @Return = 1 

END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	Set @Return = 0
END CATCH


RETURN @Return

GO
