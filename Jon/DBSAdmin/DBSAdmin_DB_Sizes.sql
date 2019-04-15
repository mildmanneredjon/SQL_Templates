/** Without Drive Letter */
SELECT DISTINCT
	S.MachineName
	,S.ServerName AS [SQL_ServerName]
	,DF.database_name
	,SUM(DF.size_in_mb) AS Database_Size_MB
	,SUM(DF.size_in_gb) AS Database_Size_GB
FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
JOIN [DBS_DW].[dbo].[vw_SQL_Database_Files_Latest] DF
	ON S.MonitoredItem_GUID = DF.MonitoredItem_GUID
WHERE S.MachineName IN ('ukswaksentinal') 
GROUP BY S.MachineName
	,S.ServerName 
	,DF.database_name
--WITH ROLLUP

/** With Drive Letter 
SELECT DISTINCT
	S.MachineName
	,S.ServerName AS [SQL_ServerName]
	,DF.database_name
	,DF.Drive_Letter
	,SUM(DF.size_in_mb) AS Database_Size_MB
	,SUM(DF.size_in_gb) AS Database_Size_GB
FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
JOIN [DBS_DW].[dbo].[vw_SQL_Database_Files_Latest] DF
	ON S.MonitoredItem_GUID = DF.MonitoredItem_GUID
WHERE S.MachineName IN ('rssshadow') 
GROUP BY S.MachineName
	,S.ServerName 
	,DF.database_name
	,DF.Drive_Letter
--WITH ROLLUP
*/