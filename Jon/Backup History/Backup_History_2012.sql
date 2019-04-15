DECLARE @DBNAME NVARCHAR(100)
SET @DBNAME = 'bps'

SELECT DISTINCT TOP 1000 
a.[backup_set_id]
,a.[media_set_id]
,a.[database_name]
,a.[backup_size] 
,a.[backup_size] / 1024 / 1024 as backup_size_MB
,a.compressed_backup_size / 1024 /1024 as compressed_size_MB
,a.[type]
,a.[backup_start_date]
,a.[backup_finish_date]
,DATEDIFF(MINUTE,a.[backup_start_date],a.[backup_finish_date])/60 AS TIMELAPSE_HOUR
,DATEDIFF(MINUTE,a.[backup_start_date],a.[backup_finish_date]) AS TIMELAPSE_MIN
,a.[server_name]
,a.[machine_name]
,b.[logical_device_name]
,b.[physical_device_name]
,a.[description]
,a.[user_name]
,a.[database_creation_date]
      
  FROM [msdb].[dbo].[backupset] a
INNER JOIN [msdb].[dbo].[backupmediafamily] b
	ON a.[media_set_id] = b.[media_set_id]

WHERE [database_name] = @DBNAME
AND a.[type] = 'D'
--AND a.[type] IN ('D','I')
ORDER BY [backup_start_date] DESC