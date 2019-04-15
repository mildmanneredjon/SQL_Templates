USE master;
SET NOCOUNT ON
SET QUOTED_IDENTIFIER ON

IF(SELECT role_desc FROM sys.dm_hadr_availability_replica_states WHERE is_local = 1) = 'PRIMARY'
BEGIN

	/******************************************************
	Delete AND create msdb.dbo.index_frag_report table
	******************************************************/
	IF EXISTS (SELECT * FROM msdb.sys.objects WHERE type = 'U' AND name = 'index_frag_report')
	BEGIN
		TRUNCATE TABLE msdb.dbo.index_frag_report
	END
	ELSE
	BEGIN
		CREATE TABLE msdb.dbo.index_frag_report 
		(
		[ID] INT IDENTITY(1,1),
		[servername] VARCHAR(100),
		[Database_Name] VARCHAR(100),
		[is_read_only] TINYINT,
		[recovery_model_desc] VARCHAR(12),
		[Table] VARCHAR(100),
		[index_id] INT,
		[partition_number] TINYINT,
		[partition_count] TINYINT,
		[index_name] VARCHAR(100),
		[avg_fragmentation_in_percent] INT,
		[Index_Type] VARCHAR(15),
		[Index_Defrag_Type] VARCHAR(10),
		[indexsize_mb] DECIMAL(20,3),
		[table_row_count] BIGINT,
		[page_count] BIGINT,
		[defrag_start] DATETIME,
		[defrag_end] DATETIME,
		[min_diff] SMALLINT,
		[error_message] VARCHAR(MAX)
		)
	END

	/******************************************************
	Declare table variables required
	******************************************************/
	DECLARE @dbtable TABLE ([ID] INT IDENTITY(1,1), dbname VARCHAR(100), is_read_only BIT, recovery_model_desc VARCHAR(12))
	DECLARE @table TABLE ([ID] INT IDENTITY(1,1), dbname VARCHAR(100),is_read_only BIT, recovery_model_desc VARCHAR(12) ,table_name VARCHAR(100))
	DECLARE @stat_table TABLE (ID INT IDENTITY(1,1),TABLE_NAME VARCHAR(200))
	DECLARE @table_log_free_space TABLE (DatabaseName VARCHAR(100),	LogSizeMB DECIMAL(10,2),LogSpaceUsed DECIMAL(10,2),	LogStatus VARCHAR(1));

	/******************************************************
	Declare variables required
	******************************************************/
	DECLARE @db SYSNAME
	DECLARE @db2 SYSNAME
	DECLARE @db_id INT
	DECLARE @table_name VARCHAR(200)
	DECLARE @table_id INT
	DECLARE @indname VARCHAR(100)
	DECLARE @tablename VARCHAR(100)
	DECLARE @index_type VARCHAR(15)
	DECLARE @Run_Defrag TINYINT
	DECLARE @defrag_by_partition TINYINT
	DECLARE @partition TINYINT
	DECLARE @partition_count TINYINT
	DECLARE @fraglevel TINYINT
	DECLARE @defrag_type VARCHAR(11)
	DECLARE @frag_perc TINYINT
	DECLARE @readonly TINYINT
	DECLARE @table_row_count BIGINT
	DECLARE @ITEM_COUNTER INT
	DECLARE @LOOP_COUNTER INT
	DECLARE @recovery_model_desc VARCHAR(12)
	DECLARE @logfile VARCHAR(50)
	DECLARE @log_script NVARCHAR(100)
	DECLARE @log_space NVARCHAR(500)
	DECLARE @used_log_space DECIMAL(4,1)

	/******************************************************
	Set variable values
	******************************************************/

	SET @Run_Defrag = 0 --Set to 1 IF defrag is required
	SET @defrag_by_partition = 1 --Set to 1 if partition defrag is required
	SET @fraglevel = 10 --This is the level of fragmentation limit

	/******************************************************
	Populate @dbtable with all databases on the server (excluding system databases)
	******************************************************/
	INSERT INTO @dbtable (dbname, is_read_only, recovery_model_desc)
	SELECT name, is_read_only, recovery_model_desc
	FROM master.sys.databases 
	WHERE state_desc = 'ONLINE'
	AND user_access_desc = 'MULTI_USER'
	AND source_database_id IS NULL
	AND database_id > 4
	AND NAME = 'application'
	ORDER BY name

	/******************************************************
	Populate @table with all tables FROM all databases in the @dbtable
	******************************************************/
	SET @LOOP_COUNTER = (SELECT COUNT(1) FROM @dbtable)
	SET @ITEM_COUNTER = 1

	WHILE @LOOP_COUNTER > 0 AND @ITEM_COUNTER <= @LOOP_COUNTER
	BEGIN
		SELECT 
		@db = dbname,
		@readonly = is_read_only,
		@recovery_model_desc = recovery_model_desc
		FROM @dbtable
		WHERE ID = @ITEM_COUNTER

		INSERT INTO @table (dbname, is_read_only, recovery_model_desc, table_name)
		EXEC (N'use ' + N'[' + @db + N'];SELECT  '''+@db+''','''+@readonly+''','''+@recovery_model_desc+''', ''[''+ TABLE_SCHEMA + '']''+ ''.''+ ''[''+TABLE_NAME + '']'' FROM INFORMATION_SCHEMA.TABLES F JOIN SYS.SCHEMAS S ON F.TABLE_SCHEMA = S.NAME JOIN SYS.OBJECTS O ON F.TABLE_NAME = O.NAME JOIN SYS.INDEXES I ON O.OBJECT_ID = I.OBJECT_ID WHERE F.TABLE_NAME <> ''dtproperties'' AND F.TABLE_TYPE = ''BASE TABLE'' AND I.NAME IS NOT NULL GROUP BY F.TABLE_SCHEMA, F.TABLE_NAME ORDER BY F.TABLE_SCHEMA, F.TABLE_NAME')
		
		SET @ITEM_COUNTER = @ITEM_COUNTER + 1
	END

	/******************************************************
	Set the database id AND table id AND run the fragmentation procedure
	using the tables in the @table table
	******************************************************/
	SET @LOOP_COUNTER = (SELECT COUNT(1) FROM @table)
	SET @ITEM_COUNTER = 1

	WHILE @LOOP_COUNTER > 0 AND @ITEM_COUNTER <= @LOOP_COUNTER
	BEGIN
		SELECT
		@db = dbname,
		@db2 = table_name,
		@readonly = is_read_only,
		@recovery_model_desc = recovery_model_desc
		FROM @table
		WHERE ID = @ITEM_COUNTER
		
		SET @table_id = (SELECT OBJECT_ID('['+@db+'].'+@db2))
		SET @db_id = (SELECT db_id(@db))

		PRINT 'Assessing table ['+@db+'].'+@db2+'. DB_ID = '+CONVERT(VARCHAR(20),@db_id)+'. Table_ID = '+CONVERT(VARCHAR(20),@table_id)

		INSERT INTO msdb.dbo.index_frag_report 
		EXEC (N'use ' + N'[' + @db + N'];
		SELECT 
		(CONVERT(NVARCHAR(255),  serverproperty(''ServerName''))) as ServerName,
		'''+@db+''',
		'''+@readonly+''',
		'''+@recovery_model_desc+''',
		'''+@db2+''',
		a.index_id, 
		PS.partition_number,
		pc.partition_count,
		b.name as index_name, 
		a.avg_fragmentation_in_percent ,
		b.TYPE_DESC,
		null,
		CONVERT(DECIMAL(20,3),CASE 
				WHEN SUM (PS.used_page_count) > SUM (CASE WHEN (PS.index_id < 2) THEN (PS.in_row_data_page_count + PS.lob_used_page_count + PS.row_overflow_used_page_count)ELSE PS.lob_used_page_count + PS.row_overflow_used_page_count END) 
				THEN CONVERT(DECIMAL(20,3),(SUM (PS.used_page_count)) - CONVERT(DECIMAL(20,3),SUM (CASE WHEN (PS.index_id < 2) THEN (PS.in_row_data_page_count + PS.lob_used_page_count + PS.row_overflow_used_page_count)ELSE PS.lob_used_page_count + PS.row_overflow_used_page_count END)) ) 
				ELSE CONVERT(DECIMAL(20,3),0 )
				END * 8 /1024) AS indexsize_mb,
		PS.row_count AS table_row_count,
		a.page_count,
		null,
		null,
		null,
		null
		FROM sys.dm_db_index_physical_stats ('+@db_id+', '''+@table_id+''',NULL, NULL, NULL) AS a 	 
		JOIN sys.indexes AS b 
			ON a.object_id = b.object_id 
			AND a.index_id = b.index_id
		JOIN sys.dm_db_partition_stats PS
			ON a.partition_number = PS.partition_number
			AND b.object_id = PS.object_id
			AND b.index_id = PS.index_id
		JOIN (SELECT object_id, index_id, COUNT(DISTINCT partition_number) AS partition_count
						   FROM sys.partitions
						   GROUP BY object_id, index_id) pc
			ON b.object_id = pc.object_id 
			AND b.index_id = pc.index_id	
		WHERE a.index_id > 0 
		AND avg_fragmentation_in_percent > '+@fraglevel+'
		AND a.page_count > 1000
		group by 
			a.index_id, 
			b.name, 
			b.TYPE_DESC,
			PS.row_count,
			PS.partition_number,
			a.avg_fragmentation_in_percent ,
			pc.partition_count,
			a.page_count
		order by a.index_id
		')
		
		SET @ITEM_COUNTER = @ITEM_COUNTER + 1
	END

	UPDATE msdb.dbo.index_frag_report 
		SET Index_Defrag_Type = 'REORGANIZE' 
		WHERE [avg_fragmentation_in_percent]< 30 
		AND [table_row_count] < 5000000

	UPDATE msdb.dbo.index_frag_report 
		SET Index_Defrag_Type = 'REBUILD'
		WHERE Index_Defrag_Type IS NULL

	/******************************************************
	Run reindex on the indexes over 20% fragmented
	******************************************************/

	IF @Run_Defrag = 1
	BEGIN
		SET @LOOP_COUNTER = (SELECT COUNT(1) FROM msdb.dbo.index_frag_report)
		SET @ITEM_COUNTER = 1

		WHILE @LOOP_COUNTER > 0 AND @ITEM_COUNTER <= @LOOP_COUNTER
		BEGIN

			SELECT 
			@db = [Database_Name],
			@indname = [index_name],
			@tablename = [Table],
			@index_type = [Index_Type],
			@partition = [partition_number],
			@partition_count = [partition_count],
			@frag_perc = [avg_fragmentation_in_percent],
			@readonly = [is_read_only],
			@table_row_count = [table_row_count],
			@recovery_model_desc = recovery_model_desc,
			@defrag_type = [Index_Defrag_Type]
			FROM msdb.dbo.index_frag_report
			WHERE ID = @ITEM_COUNTER

			PRINT 'defraging index '+@indname+' on table '+@db+'.'+@tablename+'.'+@indname
			
			UPDATE msdb.dbo.index_frag_report SET [defrag_start] = GETDATE() WHERE ID = @ITEM_COUNTER

			--Establish free log space
			ESCAPE1_:
			DELETE @table_log_free_space
			INSERT INTO @table_log_free_space EXEC('dbcc sqlperf(logspace)');

			SET @used_log_space = (SELECT LogSpaceUsed FROM @table_log_free_space WHERE DatabaseName = @db ) 

			IF @used_log_space > 90.0 
			BEGIN
				PRINT 'Waiting for transaction log to clear'
				WAITFOR DELAY '00:05:00'
				GOTO ESCAPE1_
			END
			DELETE @table_log_free_space
			
			--Set read write
			IF @readonly = 1

			BEGIN 				
				EXEC (N'alter database '+@db+N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE')
				EXEC (N'alter database '+@db+N' SET READ_WRITE')
				EXEC (N'alter database '+@db+N' SET MULTI_USER')
			END
			
			BEGIN TRY
				PRINT 'no'
				IF (SELECT @defrag_type) = 'REORGANIZE'
					BEGIN
						IF @defrag_by_partition = 0 
						BEGIN
							EXEC (N'use ' + N'[' + @db + N']; ALTER INDEX ['+@indname+'] on '+@tablename+' REORGANIZE') 
						END
						IF @defrag_by_partition = 1 AND @partition_count > 1
						BEGIN
							EXEC (N'use ' + N'[' + @db + N']; ALTER INDEX ['+@indname+'] on '+@tablename+' REORGANIZE PARTITION='+@partition) 				
						END
						IF @defrag_by_partition = 1 AND @partition_count = 1
						BEGIN
							EXEC (N'use ' + N'[' + @db + N']; ALTER INDEX ['+@indname+'] on '+@tablename+' REORGANIZE') 
						END
					
					PRINT 'Updating Statistics for: '+@db+'.'+@tablename+' '+@indname
					
					EXECUTE ('UPDATE STATISTICS '+@db+'.'+@tablename+' '+@indname)						
					
					END 
					
				IF (SELECT @defrag_type) = 'REBUILD' AND (SELECT @index_type)='CLUSTERED'
					BEGIN
						IF @defrag_by_partition = 0
						BEGIN
							EXEC (N'use ' + N'' + @db + N'; ALTER INDEX ['+@indname+'] on '+@tablename+' REBUILD WITH (SORT_IN_TEMPDB = ON,STATISTICS_NORECOMPUTE = OFF,ONLINE = ON)') 
						END
						IF @defrag_by_partition = 1 AND @partition_count > 1
						BEGIN
							EXEC (N'use ' + N'' + @db + N'; ALTER INDEX ['+@indname+'] on '+@tablename+' REBUILD PARTITION='+@partition) 		
						END
						IF @defrag_by_partition = 1 AND @partition_count = 1
						BEGIN
							EXEC (N'use ' + N'' + @db + N'; ALTER INDEX ['+@indname+'] on '+@tablename+' REBUILD WITH (SORT_IN_TEMPDB = ON,STATISTICS_NORECOMPUTE = OFF,ONLINE = ON)') 
						END
					END 

				IF (SELECT @defrag_type) = 'REBUILD' AND (SELECT @index_type)='NONCLUSTERED'
					BEGIN
						IF @defrag_by_partition = 0
						BEGIN
							EXEC (N'use ' + N'' + @db + N'; ALTER INDEX ['+@indname+'] on '+@tablename+' DISABLE') 
							EXEC (N'use ' + N'' + @db + N'; ALTER INDEX ['+@indname+'] on '+@tablename+' REBUILD WITH (SORT_IN_TEMPDB = ON,STATISTICS_NORECOMPUTE = OFF,ONLINE = ON)') 
						END
						IF @defrag_by_partition = 1 AND @partition_count > 1
						BEGIN
							EXEC (N'use ' + N'' + @db + N'; ALTER INDEX ['+@indname+'] on '+@tablename+' REBUILD PARTITION='+@partition) 		
						END
						IF @defrag_by_partition = 1 AND @partition_count = 1
						BEGIN
							EXEC (N'use ' + N'' + @db + N'; ALTER INDEX ['+@indname+'] on '+@tablename+' DISABLE') 
							EXEC (N'use ' + N'' + @db + N'; ALTER INDEX ['+@indname+'] on '+@tablename+' REBUILD WITH (SORT_IN_TEMPDB = ON,STATISTICS_NORECOMPUTE = OFF,ONLINE = ON)') 
						END
					END 
					
			END TRY
			BEGIN CATCH
				UPDATE msdb.dbo.index_frag_report SET [error_message] = ERROR_MESSAGE() WHERE ID = @ITEM_COUNTER	
			END CATCH
			
			UPDATE msdb.dbo.index_frag_report SET [defrag_end] = GETDATE() WHERE ID = @ITEM_COUNTER		
			
			UPDATE msdb.dbo.index_frag_report SET min_diff = datediff(mi,defrag_start,defrag_end) WHERE ID = @ITEM_COUNTER

			--Establish free log space
			ESCAPE2_:
			DELETE @table_log_free_space
			INSERT INTO @table_log_free_space EXEC('dbcc sqlperf(logspace)');

			SET @used_log_space = (SELECT LogSpaceUsed FROM @table_log_free_space WHERE DatabaseName = @db AND LogSpaceUsed > 90) 

			IF @used_log_space > 90.0 
			BEGIN
				PRINT 'Waiting for transaction log to clear'
				WAITFOR DELAY '00:05:00'
				GOTO ESCAPE2_
			END



			--Set back to read only
			IF @readonly = 1
			BEGIN 				
				EXEC (N'alter database '+@db+N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE')
				EXEC (N'alter database '+@db+N' SET READ_ONLY')
				EXEC (N'alter database '+@db+N' SET MULTI_USER')
			END
			
			PRINT 'index '+@indname+' on table '+@db+'.'+@tablename+'.'+@indname+' has been defraged'

			SET @ITEM_COUNTER = @ITEM_COUNTER + 1
		END
	END
END