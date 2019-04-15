/***********************
Table Sizes
***********************/

SELECT TOP 100 
[DatabaseName]
,[TableName]
,CONVERT(VARCHAR(15),[DateLogged],111) AS [DateLogged]
,DATENAME(dw,[DateLogged]) 
,[RowCount]
,SUM([DataSpaceUsed]) AS [FileUsedMB]
,SUM([DataSpaceUsed])/1024 AS [FileUsedGB]
FROM [DBSAdmin].[dbo].[TableSpaceHistory]
WHERE [TableName] = 'tbl_Hosmission_logUpload'
AND [DatabaseName] = 'Exchange'
--AND LEFT(CONVERT(VARCHAR(15),[DateLogged],114),2) = '09'
--AND DATENAME(dw,[DateLogged]) = 'Monday'
GROUP BY [DatabaseName],[TableName],[RowCount],DATENAME(dw,[DateLogged]) ,CONVERT(VARCHAR(15),[DateLogged],111)
ORDER BY CONVERT(VARCHAR(15),[DateLogged],111) DESC

/***********************
Database Sizes
***********************/
SELECT TOP 100 
[DatabaseName]
,CONVERT(VARCHAR(15),[Date],111) AS [date]
,DATENAME(dw,[Date]) 
,SUM([FileSizeMB]) AS [FileSizeMB]
,SUM([FreeSpaceMB]) AS [FreeSpaceMB]
,SUM([FileUsedMB]) AS [FileUsedMB]
,SUM([FileUsedMB])/1024 AS [FileUsedGB]
FROM [DBSAdmin].[dbo].[DataFileSpaceHistory]
WHERE databasename = 'Exchange'
and left(CONVERT(VARCHAR(15),[Date],114),2) = '09'
--and DATENAME(dw,[Date]) = 'Monday'
GROUP BY [DatabaseName],DATENAME(dw,[Date]) ,CONVERT(VARCHAR(15),[Date],111)
ORDER BY CONVERT(VARCHAR(15),[Date],111) DESC