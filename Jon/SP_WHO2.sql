USE MASTER
GO

SELECT  
	D.TEXT SQLSTATEMENT, 
	A.SESSION_ID SPID, 
	ISNULL(B.STATUS,A.STATUS) STATUS, 
	A.LOGIN_NAME LOGIN, 
	A.HOST_NAME HOSTNAME, 
	C.BLKBY,  
	C.MODE,
	DB_NAME(B.DATABASE_ID) DBNAME, 
	B.COMMAND, 
	ROUND(B.PERCENT_COMPLETE,1) AS PERC_COMP,
	(estimated_completion_time / 1000/60 /60/ 24) as Est_Days ,
	((estimated_completion_time / 1000/60 /60) % 24 ) as Est_Hours,
	((estimated_completion_time / 1000/60 ) % 60) as Est_Mins,
	((estimated_completion_time / 1000) % 60) as Est_Secs,
	ISNULL(B.CPU_TIME, A.CPU_TIME) CPUTIME, 
	--total_elapsed_time as Total_Elapsed_Time,
	--(total_elapsed_time / 1000/60 /60/ 24) as Days ,
	--((total_elapsed_time / 1000/60 /60) % 24  )as 'Hours',
	--((total_elapsed_time / 1000/60 ) % 60  )as 'Mins',
	--((total_elapsed_time / 1000) % 60  )as 'Sec'
	--A.READS,
	--A.WRITES,
	--B.READS,
	--B.WRITES,
	ISNULL((B.READS + B.WRITES),(A.READS + A.WRITES)) DISKIO,  
	A.LAST_REQUEST_START_TIME LASTBATCH, 
	A.PROGRAM_NAME
FROM    SYS.DM_EXEC_SESSIONS A    
LEFT JOIN    SYS.DM_EXEC_REQUESTS B    
	ON A.SESSION_ID = B.SESSION_ID   
LEFT JOIN (SELECT   A.REQUEST_SESSION_ID SPID, A.REQUEST_MODE MODE, B.BLOCKING_SESSION_ID BLKBY 
				FROM SYS.DM_TRAN_LOCKS AS A  
				INNER JOIN SYS.DM_OS_WAITING_TASKS AS B 
				ON A.LOCK_OWNER_ADDRESS = B.RESOURCE_ADDRESS ) C    
	ON A.SESSION_ID = C.SPID   
OUTER APPLY SYS.DM_EXEC_SQL_TEXT(SQL_HANDLE) D
WHERE D.TEXT IS NOT NULL
AND A.SESSION_ID <> (SELECT @@SPID)
--OR A.LOGIN_NAME = 'SA'

--DBCC OUTPUTBUFFER (74)

--SP_WHO2 ACTIVE

--KILL 55

/*
The lock mode requested. Can be:

 NULL = No access is granted to the resource. Serves as a placeholder.

 Sch-S = Schema stability. Ensures that a schema element, such as a table or index, is not dropped while any session holds a schema stability lock on the schema element.

 Sch-M = Schema modification. Must be held by any session that wants to change the schema of the specified resource. Ensures that no other sessions are referencing the indicated object.

 S = Shared. The holding session is granted shared access to the resource.

 U = Update. Indicates an update lock acquired on resources that may eventually be updated. It is used to prevent a common form of deadlock that occurs when multiple sessions lock resources for potential update at a later time.

 X = Exclusive. The holding session is granted exclusive access to the resource.

 IS = Intent Shared. Indicates the intention to place S locks on some subordinate resource in the lock hierarchy.

 IU = Intent Update. Indicates the intention to place U locks on some subordinate resource in the lock hierarchy.

 IX = Intent Exclusive. Indicates the intention to place X locks on some subordinate resource in the lock hierarchy.

 SIU = Shared Intent Update. Indicates shared access to a resource with the intent of acquiring update locks on subordinate resources in the lock hierarchy.

 SIX = Shared Intent Exclusive. Indicates shared access to a resource with the intent of acquiring exclusive locks on subordinate resources in the lock hierarchy.

 UIX = Update Intent Exclusive. Indicates an update lock hold on a resource with the intent of acquiring exclusive locks on subordinate resources in the lock hierarchy.

 BU = Bulk Update. Used by bulk operations.

 RangeS_S = Shared Key-Range and Shared Resource lock. Indicates serializable range scan.

 RangeS_U = Shared Key-Range and Update Resource lock. Indicates serializable update scan.

 RangeI_N = Insert Key-Range and Null Resource lock. Used to test ranges before inserting a new key into an index.

 RangeI_S = Key-Range Conversion lock. Created by an overlap of RangeI_N and S locks.

 RangeI_U = Key-Range Conversion lock created by an overlap of RangeI_N and U locks.

 RangeI_X = Key-Range Conversion lock created by an overlap of RangeI_N and X locks.

 RangeX_S = Key-Range Conversion lock created by an overlap of RangeI_N and RangeS_S. locks.

 RangeX_U = Key-Range Conversion lock created by an overlap of RangeI_N and RangeS_U locks.

 RangeX_X = Exclusive Key-Range and Exclusive Resource lock. This is a conversion lock used when updating a key in a range.
*/