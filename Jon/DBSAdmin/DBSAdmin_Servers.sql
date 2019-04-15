--HOSQUESTION\TIME

SET NOCOUNT ON;
USE DBS_DW;
SELECT 
	UPPER(S.Server_Name) AS [Server_Name]
	,D.domain_name
	,S.Manufacturer
	,S.Model
	,OS.OS_Name
	,OS.OS_Major_Version
	,OS.OS_Minor_Version
	,P.Manufacturer AS [CPU_Manufacturer]
	,P.Name AS [CPU_Name]
	,P.[NumberOfCores]
	,P.[NumberOfLogicalProcessors]
	,SUM(LD.Size_MB) AS [Total_Disk_Size_mb]
	,CASE WHEN [NumberOfLogicalProcessors] IS NULL THEN COUNT(P.DeviceID)
		ELSE P.[NumberOfCores] * P.[NumberOfLogicalProcessors] END AS [TotalProcessors]
	,SQLS.ServerName AS [SQL_ServerName]
	,SQLS.ProductVersion AS [SQL_ProductVersion]
	,SQLS.ProductLevel AS [SQL_ProductLevel]
	,SQLS.Edition AS [SQL_Edition]
	,SQLS.Port_Number AS [SQL_Port_Number]
	,COUNT(SQLD.name) AS [Number_of_Databases]
FROM [Servers].[Server] S
JOIN [Servers].[Operating_System] OS
	ON S.OS_id = OS.OS_id
JOIN [Environment].[Domain] D
	ON S.Domain_id = D.domain_id
JOIN (SELECT DISTINCT
			SystemName
			,Manufacturer
			,Name
			,DeviceID
			,[NumberOfCores]
			,[NumberOfLogicalProcessors]
		FROM [DBS_DW].[Servers].[Processors] ) P
	ON S.Server_Name = P.SystemName
JOIN [dbo].[vw_SQL_Servers_Latest] SQLS
	ON S.Server_id = SQLS.Windows_Server_id
JOIN [dbo].[vw_SQL_Database_Latest] SQLD
	ON SQLS.ServerName = SQLD.Server_Name
JOIN [dbo].[vw_Server_LogicalDisks_Latest] LD
	ON S.Server_Name = LD.Server_Name


WHERE S.Server_Name like 'HOHRDB0%'

GROUP BY 
	UPPER(S.Server_Name) 
	,D.domain_name
	,S.Manufacturer
	,S.Model
	,OS.OS_Name
	,OS.OS_Major_Version
	,OS.OS_Minor_Version
	,P.Manufacturer
	,P.Name
	,P.[NumberOfCores]
	,P.[NumberOfLogicalProcessors]
	,SQLS.ServerName
	,SQLS.ProductVersion
	,SQLS.ProductLevel
	,SQLS.Edition
	,SQLS.Port_Number
ORDER BY [Server_Name]