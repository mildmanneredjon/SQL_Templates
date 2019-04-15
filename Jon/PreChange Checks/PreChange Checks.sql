USE MASTER
GO

/*Check for running backups, index rebuilds and SQL agents jobs*/

SELECT  
	D.TEXT SQLSTATEMENT, 
	A.SESSION_ID SPID, 
	ISNULL(B.STATUS,A.STATUS) STATUS, 
	A.LOGIN_NAME LOGIN, 
	A.HOST_NAME HOSTNAME, 
	DB_NAME(B.DATABASE_ID) DBNAME, 
	B.COMMAND, 
	ROUND(B.PERCENT_COMPLETE,1) AS PERC_COMP,
	A.LAST_REQUEST_START_TIME LASTBATCH, 
	A.PROGRAM_NAME
FROM    SYS.DM_EXEC_SESSIONS A    
LEFT JOIN    SYS.DM_EXEC_REQUESTS B    
	ON A.SESSION_ID = B.SESSION_ID   
OUTER APPLY SYS.DM_EXEC_SQL_TEXT(SQL_HANDLE) D
WHERE D.TEXT IS NOT NULL
AND A.SESSION_ID <> (SELECT @@SPID)
AND (B.COMMAND IN ('BACKUP DATABASE', 'ALTER INDEX') OR (A.PROGRAM_NAME LIKE 'SQLAgent - TSQL JobStep %'))

/*Check for failed SQL agent jobs*/
USE msdb
GO

SELECT DISTINCT
dbo.agent_datetime(SJH.run_date, SJH.run_time) 'Start Date Time'
,SJH.job_id
,SJ.name
,CASE SJH.run_status 
	WHEN 0 THEN 'Failed'
	WHEN 1 THEN 'Succeeded'
	WHEN 2 THEN 'Retry'
	WHEN 3 THEN 'Canceled'
	ELSE 'Unknown'
	END  AS run_Status

FROM [dbo].[sysjobhistory] SJH
JOIN [dbo].[sysjobs] SJ
	ON SJH.job_id = SJ.job_id

WHERE dbo.agent_datetime(SJH.run_date, SJH.run_time) = (
	SELECT MAX(dbo.agent_datetime(run_date, run_time)) FROM [dbo].[sysjobhistory] WHERE job_id = SJH.job_id)
AND SJH.run_status = 0
ORDER BY SJ.name
