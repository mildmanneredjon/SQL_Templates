DECLARE @DBNAME VARCHAR(50)
DECLARE @ITEM_COUNTER INT
DECLARE @LOOP_COUNTER INT
DECLARE @TABLE1 TABLE (ID INT IDENTITY(1,1),DBNAME VARCHAR(50))
DECLARE @TABLE2 TABLE (
	[SERVER_NAME] [nvarchar](128) ,
	[DATABASE_NAME] [nvarchar](128) ,
	[TABLE_NAME] [sysname] ,
	[INDEX_NAME] [sysname] ,
	[INDEX_ID] [int] ,
	[PARTITION_NUMBER] [int],
	[TYPE_DESC] [nvarchar](60) ,
	[USER_SEEKS] [bigint] ,
	[USER_SCANS] [bigint] ,
	[USER_LOOKUPS] [bigint] ,
	[USER_UPDATES] [bigint] ,
	[LAST_USER_SEEK] [datetime],
	[LAST_USER_SCAN] [datetime],
	[LAST_USER_LOOKUP] [datetime],
	[INDEXSIZE_MB] [decimal](20,3),
	[TABLE_ROW_COUNT] [bigint]
)
                            
INSERT INTO @TABLE1 (DBNAME)
SELECT [NAME] FROM SYS.SYSDATABASES WHERE [DBID] > 4 AND [NAME] <> 'DBSadmin' AND [NAME] NOT LIKE 'Report%'

SET @LOOP_COUNTER = (SELECT COUNT(1) FROM @TABLE1)
SET @ITEM_COUNTER = 1

WHILE @LOOP_COUNTER > 0 AND @ITEM_COUNTER <= @LOOP_COUNTER
BEGIN

	SELECT 
		@DBNAME = DBNAME
	FROM @TABLE1
	WHERE ID = @ITEM_COUNTER
	INSERT INTO @TABLE2([SERVER_NAME],[DATABASE_NAME],[TABLE_NAME],[INDEX_NAME],[INDEX_ID],[PARTITION_NUMBER],[TYPE_DESC],[USER_SEEKS],[USER_SCANS],[USER_LOOKUPS],[USER_UPDATES],[LAST_USER_SEEK],[LAST_USER_SCAN],[LAST_USER_LOOKUP],[INDEXSIZE_MB],[TABLE_ROW_COUNT])
	EXEC (N'USE ' + N'[' + @DBNAME + N'];
	SELECT 
		@@SERVERNAME AS SERVER_NAME
		,DB_NAME() AS DATABASE_NAME
		,O.NAME AS TABLE_NAME
		,I.NAME INDEX_NAME 
		,I.INDEX_ID
		,PS.PARTITION_NUMBER
		,I.TYPE_DESC 
		,S.USER_SEEKS
		,S.USER_SCANS
		,S.USER_LOOKUPS
		,S.USER_UPDATES
		,S.LAST_USER_SEEK
		,S.LAST_USER_SCAN
		,S.LAST_USER_LOOKUP
		,CONVERT(DECIMAL(20,3),CASE 
			WHEN SUM (PS.used_page_count) > SUM (CASE WHEN (PS.index_id < 2) THEN (PS.in_row_data_page_count + PS.lob_used_page_count + PS.row_overflow_used_page_count)ELSE PS.lob_used_page_count + PS.row_overflow_used_page_count END) 
			THEN CONVERT(DECIMAL(20,3),(SUM (PS.used_page_count)) - CONVERT(DECIMAL(20,3),SUM (CASE WHEN (PS.index_id < 2) THEN (PS.in_row_data_page_count + PS.lob_used_page_count + PS.row_overflow_used_page_count)ELSE PS.lob_used_page_count + PS.row_overflow_used_page_count END)) ) 
			ELSE CONVERT(DECIMAL(20,3),0 )
			END * 8 /1024) AS INDEXSIZE_MB
		,PS.row_count AS TABLE_ROW_COUNT
	FROM SYS.OBJECTS AS O
	JOIN SYS.INDEXES AS I
		ON O.OBJECT_ID = I.OBJECT_ID 
	LEFT OUTER JOIN SYS.DM_DB_INDEX_USAGE_STATS AS S    
		ON I.OBJECT_ID = S.OBJECT_ID   AND I.INDEX_ID = S.INDEX_ID AND S.DATABASE_ID = DB_ID()
	JOIN sys.dm_db_partition_stats PS
		ON O.OBJECT_ID = PS.OBJECT_ID
		AND I.INDEX_ID = PS.INDEX_ID
	WHERE  O.NAME <> ''dtproperties''
	AND O.TYPE = ''U''
	AND I.TYPE IN (1, 2) 
	AND USER_SEEKS IS NOT NULL
	AND I.IS_DISABLED = 0
	GROUP BY 
		O.NAME, 
		O.OBJECT_ID
		,I.NAME
		,I.INDEX_ID
		,PS.PARTITION_NUMBER
		,I.TYPE_DESC 
		,S.USER_SEEKS
		,S.USER_SCANS
		,S.USER_LOOKUPS
		,S.USER_UPDATES
		,S.LAST_USER_SEEK
		,S.LAST_USER_SCAN
		,S.LAST_USER_LOOKUP
		,PS.ROW_COUNT
	')
	
	SET @ITEM_COUNTER = @ITEM_COUNTER + 1

END

SELECT * 
FROM @TABLE2 
WHERE USER_UPDATES > 0
AND USER_SEEKS = 0
AND USER_SCANS = 0
AND USER_LOOKUPS = 0
ORDER BY [DATABASE_NAME],[TABLE_NAME],[INDEX_NAME]

--,CASE 
--	WHEN SUM (PS.used_page_count) > SUM (CASE WHEN (PS.index_id < 2) THEN (PS.in_row_data_page_count + PS.lob_used_page_count + PS.row_overflow_used_page_count)ELSE PS.lob_used_page_count + PS.row_overflow_used_page_count END) 
--	THEN (SUM (PS.used_page_count) - SUM (CASE WHEN (PS.index_id < 2) THEN (PS.in_row_data_page_count + PS.lob_used_page_count + PS.row_overflow_used_page_count)ELSE PS.lob_used_page_count + PS.row_overflow_used_page_count END) ) 
--	ELSE 0 
--	END * 8 AS INDEXSIZE_KB