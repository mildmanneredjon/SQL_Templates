USE SSISDB;

/* Declare Variables */

DECLARE @FOLDER VARCHAR(100) = 'HC_DWH'
DECLARE @PROJECT VARCHAR(100) = 'ETLStaging1'
DECLARE @PACKAGE VARCHAR(100) = 'DW_AGREEMENT_HISTORIC_DATA_TABLE_STG.dtsx'

SELECT 
	F.[folder_id]
	,F.[name] AS [folder_name]
	,PR.project_id
	,PR.name AS [project_name]
	,PA.package_id 
	,PA.name AS [package_name]
	,CASE  
		WHEN EX.status = 1 THEN 'Created'
		WHEN EX.status = 2 THEN 'Running'
		WHEN EX.status = 3 THEN 'Canceled'
		WHEN EX.status = 4 THEN 'Failed'
		WHEN EX.status = 5 THEN 'Pending'
		WHEN EX.status = 6 THEN 'Ended Unexpectedly'
		WHEN EX.status = 7 THEN 'Succeeded'
		WHEN EX.status = 8 THEN 'Stopping'
		WHEN EX.status = 9 THEN 'Completed'
	ELSE 'Unknown'
	END
	,DATEDIFF(MINUTE,EX.start_time,EX.end_time) AS [duration]
	,EX.start_time
	,EX.end_time
FROM [catalog].[folders] F
JOIN [catalog].[projects] PR
	ON F.folder_id = PR.folder_id
JOIN [catalog].[packages] PA
	ON PR.project_id = PA.project_id
JOIN [catalog].[executions] EX
	ON EX.folder_name = F.name
	AND EX.project_name = PR.name
	AND EX.package_name = PA.name
WHERE F.name = @FOLDER
AND PR.name = @PROJECT
AND PA.name = @PACKAGE

/* Status:
EX.status = 1 THEN Created
EX.status = 2 THEN Running
EX.status = 3 THEN Canceled
EX.status = 4 THEN Failed
EX.status = 5 THEN Pending
EX.status = 6 THEN Ended Unexpectedly
EX.status = 7 THEN Succeeded
EX.status = 8 THEN Stopping
EX.status = 9 THEN Completed
*/