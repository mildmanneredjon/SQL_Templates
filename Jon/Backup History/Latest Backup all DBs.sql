SELECT 
	max(a.[backup_set_id]) as [backup_set_id]
	,a.[database_name]
	,a.[server_name]
	,CASE WHEN b.[logical_device_name] IS NULL AND b.[physical_device_name] LIKE ('%Data Protector%') THEN 'Data Protector'
		ELSE b.[logical_device_name] END AS [logical_device_name]
	,b.[physical_device_name]
	,a.[backup_start_date]
	,a.[backup_finish_date]
	,DATEDIFF(MINUTE, a.[backup_start_date], a.[backup_finish_date]) AS [backup_duration]
	,a.[type]
	,a.[backup_size]
FROM [msdb].[dbo].[backupset] a
INNER JOIN [msdb].[dbo].[backupmediafamily] b
	ON a.[media_set_id] = b.[media_set_id]
INNER JOIN [master]..sysdatabases c
	ON c.name COLLATE DATABASE_DEFAULT = a.[database_name] COLLATE DATABASE_DEFAULT 
WHERE a.[backup_set_id] in (
		SELECT 
		max(a.[backup_set_id])
		FROM [msdb].[dbo].[backupset] a
		INNER JOIN [msdb].[dbo].[backupmediafamily] b
			ON a.[media_set_id] = b.[media_set_id]
		INNER JOIN [master]..sysdatabases c
			ON c.name COLLATE DATABASE_DEFAULT
		 = a.[database_name] COLLATE DATABASE_DEFAULT 
		 WHERE a.[type] = 'D'
		 GROUP BY a.[database_name])
GROUP BY a.[database_name]
,a.[server_name]
,b.[logical_device_name]
,b.[physical_device_name]
,a.[backup_start_date]
,a.[backup_finish_date]
,a.[type]
,a.[backup_size]
ORDER BY [database_name]

--**********************************************
DECLARE @DATABASENAME VARCHAR(20)
SET @DATABASENAME = 'DW_Sales_ODS'

SELECT DISTINCT TOP 10 
	a.[backup_set_id]
	,a.[database_name]
	,a.[server_name]
	,CASE WHEN b.[logical_device_name] IS NULL AND b.[physical_device_name] LIKE ('%Data Protector%') THEN 'Data Protector'
		ELSE b.[logical_device_name] END AS [logical_device_name]
	,b.[physical_device_name]
	,a.[backup_start_date]
	,a.[backup_finish_date]
	,DATEDIFF(MINUTE, a.[backup_start_date], a.[backup_finish_date]) AS [backup_duration]
	,a.[type]
	,a.[backup_size]
FROM [msdb].[dbo].[backupset] a
INNER JOIN [msdb].[dbo].[backupmediafamily] b
	ON a.[media_set_id] = b.[media_set_id]
INNER JOIN [master]..sysdatabases c
	ON c.name COLLATE DATABASE_DEFAULT = a.[database_name] COLLATE DATABASE_DEFAULT 
WHERE a.[backup_set_id] in (
		SELECT 
		a.[backup_set_id]
		FROM [msdb].[dbo].[backupset] a
		INNER JOIN [msdb].[dbo].[backupmediafamily] b
			ON a.[media_set_id] = b.[media_set_id]
		INNER JOIN [master]..sysdatabases c
			ON c.name COLLATE DATABASE_DEFAULT
		 = a.[database_name] COLLATE DATABASE_DEFAULT 
		 WHERE a.[type] = 'D'
		 AND a.[database_name] = @DATABASENAME
		 )
ORDER BY a.[backup_start_date] DESC

/*
SELECT 
	a.*
--,b.*
--,c.*
FROM [msdb].[dbo].[backupset] a
INNER JOIN [msdb].[dbo].[backupmediafamily] b
	ON a.[media_set_id] = b.[media_set_id]
INNER JOIN [master]..sysdatabases c
	ON c.name COLLATE DATABASE_DEFAULT = a.[database_name] COLLATE DATABASE_DEFAULT 
WHERE database_name = 'stratagem'
and backup_start_date between '2009-07-17 00:21:16.000' and '2009-07-17 17:21:16.000'
ORDER BY [database_name]
*/
