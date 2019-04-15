USE DBSAdmin;

/******** Database File Growth**********/  
DECLARE @DBNAME VARCHAR(100)
SET @DBNAME = 'PerformanceCohorts_FocalPoint'

SELECT TOP 100 
[DatabaseName]
,CONVERT(VARCHAR(15),[Date],111) as [date]
,DATENAME(dw,[Date]) 
,SUM([FileUsedMB]) as [FileUsedMB]
,SUM([FileUsedMB])/1024 as [FileUsedGB]
,SUM([FreeSpaceMB]) as [FreeSpaceMB]
,SUM([FreeSpaceMB])/1024 as [FreeSpaceGB]
FROM [DBSAdmin].[dbo].[DataFileSpaceHistory]
WHERE databasename = @DBNAME
AND LEFT(CONVERT(VARCHAR(15),[Date],114),2) = '00'
AND DATENAME(dw,[Date]) = 'Monday'
GROUP BY [DatabaseName],DATENAME(dw,[Date]) ,CONVERT(VARCHAR(15),[Date],111)
ORDER BY CONVERT(VARCHAR(15),[Date],111) DESC

SELECT TOP 1000 [ID]
      ,[Date]
      ,left(CONVERT(VARCHAR(15),[Date],114),2) as [date]
      ,[SQLServer]
      ,[DatabaseName]
      ,[FileName]
      ,[PhysicalName]
      ,[FileSizeMB]
      ,[FileUsedMB]
      ,[FileMaxSizeMB]
      ,[FreeSpaceMB]
      ,[Growth]
      ,[IsPercentGrowth]
      ,[Alert]
  FROM [DBSAdmin].[dbo].[DataFileSpaceHistory]
  WHERE databasename = @DBNAME
  AND CONVERT(VARCHAR(15),[Date],111) = '2012/06/22'
  AND LEFT(CONVERT(VARCHAR(15),[Date],114),2) = '00'
  ORDER BY [ID] DESC

/********* Log File Growth*********/ 
SELECT TOP 100 
[DatabaseName]
,CONVERT(VARCHAR(15),[Date],111) as [date]
,DATENAME(dw,[Date]) 
,SUM([LogFileUsedMB]) as [FileUsedMB]
,SUM([LogFileUsedMB])/1024 as [FileUsedGB]
,SUM([LogFileFreeMB]) as [FreeSpaceMB]
,SUM([LogFileFreeMB])/1024 as [FreeSpaceGB]
FROM [DBSAdmin].[dbo].[LogFileSpaceHistory]
WHERE databasename = @DBNAME
AND LEFT(CONVERT(VARCHAR(15),[Date],114),2) = '00'
AND DATENAME(dw,[Date]) = 'Monday'
GROUP BY [DatabaseName],DATENAME(dw,[Date]) ,CONVERT(VARCHAR(15),[Date],111)
ORDER BY CONVERT(VARCHAR(15),[Date],111) DESC
