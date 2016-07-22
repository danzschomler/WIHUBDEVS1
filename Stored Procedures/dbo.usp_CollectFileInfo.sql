SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_CollectFileInfo] AS
Declare @Return bit; Set @Return = 0

BEGIN TRANSACTION

BEGIN TRY

	DECLARE @sqlstring NVARCHAR(MAX);
	DECLARE @DBName NVARCHAR(257);

	DECLARE DBCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY
	FOR
		SELECT  QUOTENAME([name])
		FROM    [sys].[databases]
		WHERE   [state] = 0
		ORDER BY [name];

	BEGIN
		OPEN DBCursor;
		FETCH NEXT FROM DBCursor INTO @DBName;
		WHILE @@FETCH_STATUS <> -1 
			BEGIN
				SET @sqlstring = N'USE ' + @DBName + '
		  ; INSERT DBA_Maint.[dbo].[localFileInfo] (
		  [DatabaseName],
		  [FileID],
		  [Type],
		  [DriveLetter],
		  [LogicalFileName],
		  [PhysicalFileName],
		  [SizeMB],
		  [SpaceUsedMB],
		  [FreeSpaceMB],
		  [MaxSize],
		  [IsPercentGrowth],
		  [Growth],
		  [CaptureDate]
		  )
		  SELECT ''' + @DBName
					+ ''' 
		  ,[file_id],
		   [type],
		  substring([physical_name],1,1),
		  [name],
		  [physical_name],
		  CAST([size] as DECIMAL(38,0))/128., 
		  CAST(FILEPROPERTY([name],''SpaceUsed'') AS DECIMAL(38,0))/128., 
		  (CAST([size] as DECIMAL(38,0))/128) - (CAST(FILEPROPERTY([name],''SpaceUsed'') AS DECIMAL(38,0))/128.),
		  [max_size],
		  [is_percent_growth],
		  [growth],
		  GETDATE()
		  FROM ' + @DBName + '.[sys].[database_files];'
				EXEC (@sqlstring)
				FETCH NEXT FROM DBCursor INTO @DBName;
			END

		CLOSE DBCursor;
		DEALLOCATE DBCursor;
	END

	Set @Return = 1
END TRY

BEGIN CATCH
	--ROLLBACK TRANSACTION
	Set @Return = 0
END CATCH

COMMIT TRANSACTION
Return @Return

GO
