USE MSDB
GO

DECLARE @JOB_NAME VARCHAR(100) = 'Satsuma Incremental Load (1am)'
DECLARE @MAX_SESSION SMALLINT = (SELECT MAX(JA.SESSION_ID) FROM [dbo].[sysjobactivity] JA JOIN [dbo].[sysjobs] J ON JA.job_id = J.job_id WHERE J.name = @JOB_NAME)

SELECT 
	A.[SESSION_ID]
	,B.name AS JOB_NAME
	,A.[JOB_ID]
	,ISNULL(A.last_executed_step_id,0)+1 AS current_executed_step_id
	,A.[START_EXECUTION_DATE] AS Job_Start_Date
	,A.[LAST_EXECUTED_STEP_ID]
	,A.[LAST_EXECUTED_STEP_DATE]
	,A.[STOP_EXECUTION_DATE]
	,A.[JOB_HISTORY_ID]
	,A.[NEXT_SCHEDULED_RUN_DATE]
	FROM [SYSJOBACTIVITY] A
	INNER JOIN SYSJOBS B
		ON A.JOB_ID = B.JOB_ID
	JOIN msdb.dbo.sysjobsteps js
		ON A.job_id = JS.job_id
    AND ISNULL(A.last_executed_step_id,0)+1 = js.step_id
	WHERE B.NAME LIKE 'Satsuma Incremental Load (1am)'
	AND [START_EXECUTION_DATE] IS NOT NULL
	AND A.session_id = @MAX_SESSION

GO