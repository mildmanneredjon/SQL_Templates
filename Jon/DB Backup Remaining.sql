SELECT 
	session_id,
	CONVERT(NVARCHAR(22),db_name(databASe_id)) AS [database],
	CASE command
	WHEN 'BACKUP DATABASE' THEN 'DB'
	WHEN 'RESTORE DATABASE' THEN 'DB RESTORE'
	WHEN 'RESTORE VERIFYON' THEN 'VERIFYING'
	WHEN 'RESTORE HEADERON' THEN 'VERIFYING HEADER'
	WHEN 'RESTORE HEADERONLY' THEN 'VERIFYING HEADER'
	else 'LOG' END AS [type],
	start_time AS [started],
	DATEADD(mi,estimated_completion_time/60000,GETDATE()) AS [finishing],
	DATEDIFF(mi, GETDATE(), (DATEADD(mi,estimated_completion_time/60000,GETDATE()))) [mins left],
	DATEDIFF(mi, start_time, (DATEADD(mi,estimated_completion_time/60000,GETDATE()))) AS [total wait mins (est)],
	CONVERT(varchar(5),cASt((percent_complete) AS DECIMAL (4,1))) AS [% complete],
	GETDATE() AS [current time]
FROM sys.dm_exec_requests
WHERE command in ('BACKUP DATABASE','BACKUP LOG','RESTORE DATABASE','RESTORE VERIFYON','RESTORE HEADERON','RESTORE HEADERONLY')

