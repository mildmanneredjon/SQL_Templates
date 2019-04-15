/*********************/
/* Distinct Machines */
/*********************/
SELECT 
	COUNT(DISTINCT S.MachineName) AS [Distinct_Machines]
FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
LEFT JOIN [DBS_DW].[dbo].[vw_Server_Latest] SL
	ON S.Windows_Server_id = SL.Windows_Server_id
WHERE Contact_Lost = 0
--JOIN [DBS_DW].[dbo].[vw_SQL_Database_Files_Latest] DF
--	ON S.MonitoredItem_GUID = DF.MonitoredItem_GUID
--WHERE DF.database_name IS NOT NULL

/***********************/
/* Distinct Instances */
/***********************/
SELECT 
	COUNT(DISTINCT S.ServerName) AS [Distinct_Instances]
FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
LEFT JOIN [DBS_DW].[dbo].[vw_Server_Latest] SL
	ON S.Windows_Server_id = SL.Windows_Server_id
WHERE Contact_Lost = 0
--JOIN [DBS_DW].[dbo].[vw_SQL_Database_Files_Latest] DF
--	ON S.MonitoredItem_GUID = DF.MonitoredItem_GUID
--WHERE DF.database_name IS NOT NULL

/*************/
/* Databases */
/*************/
SELECT 
	CONVERT(VARCHAR, CAST(COUNT(1) AS MONEY),1) AS [Number of Databases]
FROM 
(
	SELECT DISTINCT
		S.MachineName
		,S.ServerName AS [SQL_ServerName]
		,DF.database_name
	FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
	JOIN [DBS_DW].[dbo].[vw_SQL_Database_Files_Latest] DF
		ON S.MonitoredItem_GUID = DF.MonitoredItem_GUID
	LEFT JOIN [DBS_DW].[dbo].[vw_Server_Latest] SL
		ON S.Windows_Server_id = SL.Windows_Server_id
	WHERE DF.database_name NOT IN ('master','msdb','model','tempdb')
	AND DF.database_name IS NOT NULL
	AND Contact_Lost = 0
) AS Count_of_Databases

/***********************/
/* Total Database Size */
/***********************/
SELECT DISTINCT
	CONVERT(VARCHAR, CAST(SUM(DF.size_in_mb) AS MONEY),1) AS Database_Size_MB
	,CONVERT(VARCHAR, CAST(SUM(DF.size_in_gb) AS MONEY),1) AS Database_Size_GB
	,CONVERT(VARCHAR, CAST(SUM(DF.size_in_gb)/1024 AS MONEY),1) AS Database_Size_TB
FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
JOIN [DBS_DW].[dbo].[vw_SQL_Database_Files_Latest] DF
	ON S.MonitoredItem_GUID = DF.MonitoredItem_GUID
LEFT JOIN [DBS_DW].[dbo].[vw_Server_Latest] SL
	ON S.Windows_Server_id = SL.Windows_Server_id
WHERE DF.database_name NOT IN ('master','msdb','model','tempdb')
AND DF.database_name IS NOT NULL
AND Contact_Lost = 0;

/***********************/
/* Total_By_Version */
/***********************/
WITH Total_By_Version AS 
(
	SELECT DISTINCT 
		S.ServerName
		,s.ProductVersion
		,CASE 
			WHEN LEFT(S.ProductVersion,2) = '8.' THEN 'SQL2000'
			WHEN LEFT(S.ProductVersion,2) = '9.' THEN 'SQL2005'
			WHEN LEFT(S.ProductVersion,4) = '10.0' THEN 'SQL2008'
			WHEN LEFT(S.ProductVersion,4) = '10.5' THEN 'SQL2008R2'
			WHEN LEFT(S.ProductVersion,2) = '11' THEN 'SQL2012'
			WHEN LEFT(S.ProductVersion,2) = '12' THEN 'SQL2014'
			WHEN LEFT(S.ProductVersion,2) = '13' THEN 'SQL2016'
		END AS [SQL_Version]
	FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
	LEFT JOIN [DBS_DW].[dbo].[vw_Server_Latest] SL
		ON S.Windows_Server_id = SL.Windows_Server_id
	WHERE Contact_Lost = 0
	--JOIN [DBS_DW].[dbo].[vw_SQL_Database_Files_Latest] DF
	--	ON S.MonitoredItem_GUID = DF.MonitoredItem_GUID
	--WHERE DF.database_name IS NOT NULL
)
SELECT 
	Total_By_Version.SQL_Version
	,COUNT(1) AS Total_By_Version
FROM Total_By_Version
GROUP BY Total_By_Version.SQL_Version ;

/***********************/
/* Total_By_Version and SP */
/***********************/

WITH Total_By_Version AS 
(
	SELECT DISTINCT 
		S.ServerName
		,s.ProductVersion
		,CASE 
			WHEN LEFT(S.ProductVersion,2) = '8.' THEN 'SQL2000'
			WHEN LEFT(S.ProductVersion,2) = '9.' THEN 'SQL2005'
			WHEN LEFT(S.ProductVersion,4) = '10.0' THEN 'SQL2008'
			WHEN LEFT(S.ProductVersion,4) = '10.5' THEN 'SQL2008R2'
			WHEN LEFT(S.ProductVersion,2) = '11' THEN 'SQL2012'
			WHEN LEFT(S.ProductVersion,2) = '12' THEN 'SQL2014'
			WHEN LEFT(S.ProductVersion,2) = '13' THEN 'SQL2016'
		END AS [SQL_Version]
		,S.ProductLevel
	FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
	LEFT JOIN [DBS_DW].[dbo].[vw_Server_Latest] SL
		ON S.Windows_Server_id = SL.Windows_Server_id
	WHERE Contact_Lost = 0
	--JOIN [DBS_DW].[dbo].[vw_SQL_Database_Files_Latest] DF
	--	ON S.MonitoredItem_GUID = DF.MonitoredItem_GUID
	--WHERE DF.database_name IS NOT NULL
)
SELECT 
	Total_By_Version.SQL_Version
	,Total_By_Version.ProductLevel
	,COUNT(1) AS Total_By_Version
FROM Total_By_Version
GROUP BY Total_By_Version.SQL_Version, Total_By_Version.ProductLevel
ORDER BY Total_By_Version.SQL_Version, Total_By_Version.ProductLevel;

/************************************/
/* Total_By_Edition (Ent and Std    */
/************************************/
WITH Total_By_Edition AS 
(
	SELECT DISTINCT 
		S.ServerName
		,CASE 
			WHEN LEFT(S.Edition,9) = 'Developer' THEN 'Developer'
			WHEN LEFT(S.Edition,10) = 'Enterprise' THEN 'Enterprise'
			WHEN LEFT(S.Edition,7) = 'Express' THEN 'Express'
			WHEN LEFT(S.Edition,8) = 'Standard' THEN 'Standard'
		END AS Edition
		,SL.Contact_Lost
	FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
	LEFT JOIN [DBS_DW].[dbo].[vw_Server_Latest] SL
		ON S.Windows_Server_id = SL.Windows_Server_id
	WHERE Contact_Lost = 0
	
)
SELECT 
	Total_By_Edition.Edition
	,COUNT(1) AS Total_By_Edition
FROM Total_By_Edition

GROUP BY Total_By_Edition.Edition ;

/*******************/
/* Total_By_Role   */
/*******************/

WITH Total_By_Version_Edition AS 
(
	SELECT DISTINCT 
		S.ServerName
		,SR.Role
		,SL.Contact_Lost
	FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
	JOIN [dbo].[Server_Roles] SR
		ON s.ServerName = SR.ServerName
	LEFT JOIN [DBS_DW].[dbo].[vw_Server_Latest] SL
		ON S.Windows_Server_id = SL.Windows_Server_id
	WHERE Contact_Lost = 0
)
SELECT 
	Total_By_Version_Edition.Role
	,COUNT(1) AS Total_By_Version_Role
FROM Total_By_Version_Edition
GROUP BY Total_By_Version_Edition.Role
ORDER BY Total_By_Version_Edition.Role;


/************************************/
/* Total_By_Role_Edition (Ent and Std    */
/************************************/

WITH Total_By_Version_Edition AS 
(
	SELECT DISTINCT 
		S.ServerName
		,SR.Role
		,CASE 
			WHEN LEFT(S.Edition,9) = 'Developer' THEN 'Developer'
			WHEN LEFT(S.Edition,10) = 'Enterprise' THEN 'Enterprise'
			WHEN LEFT(S.Edition,7) = 'Express' THEN 'Express'
			WHEN LEFT(S.Edition,8) = 'Standard' THEN 'Standard'
		END AS Edition
	FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
	JOIN [dbo].[Server_Roles] SR
		ON s.ServerName = SR.ServerName
	LEFT JOIN [DBS_DW].[dbo].[vw_Server_Latest] SL
		ON S.Windows_Server_id = SL.Windows_Server_id
	WHERE Contact_Lost = 0
)
SELECT 
	Total_By_Version_Edition.Role
	,Total_By_Version_Edition.Edition
	,COUNT(1) AS Total_By_Version_Edition
FROM Total_By_Version_Edition
GROUP BY Total_By_Version_Edition.Role, Total_By_Version_Edition.Edition 
ORDER BY Total_By_Version_Edition.Role, Total_By_Version_Edition.Edition ;

/************************************/
/* Total_By_Version_Edition (Ent and Std    */
/************************************/
WITH Total_By_Version_Edition AS 
(
	SELECT DISTINCT 
		S.ServerName
		,CASE 
			WHEN LEFT(S.ProductVersion,2) = '8.' THEN 'SQL2000'
			WHEN LEFT(S.ProductVersion,2) = '9.' THEN 'SQL2005'
			WHEN LEFT(S.ProductVersion,4) = '10.0' THEN 'SQL2008'
			WHEN LEFT(S.ProductVersion,4) = '10.5' THEN 'SQL2008R2'
			WHEN LEFT(S.ProductVersion,2) = '11' THEN 'SQL2012'
			WHEN LEFT(S.ProductVersion,2) = '12' THEN 'SQL2014'
			WHEN LEFT(S.ProductVersion,2) = '13' THEN 'SQL2016'
		END AS [SQL_Version]
		,CASE 
			WHEN LEFT(S.Edition,9) = 'Developer' THEN 'Developer'
			WHEN LEFT(S.Edition,10) = 'Enterprise' THEN 'Enterprise'
			WHEN LEFT(S.Edition,7) = 'Express' THEN 'Express'
			WHEN LEFT(S.Edition,8) = 'Standard' THEN 'Standard'
		END AS Edition
	FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
	LEFT JOIN [DBS_DW].[dbo].[vw_Server_Latest] SL
		ON S.Windows_Server_id = SL.Windows_Server_id
	WHERE Contact_Lost = 0
)
SELECT 
	Total_By_Version_Edition.SQL_Version
	,Total_By_Version_Edition.Edition
	,COUNT(1) AS Total_By_Version_Edition
FROM Total_By_Version_Edition
GROUP BY Total_By_Version_Edition.SQL_Version, Total_By_Version_Edition.Edition ;


/*************************************************
*************************************************
			VIRTUAL SERVERS ONLY
*************************************************
***************************************************/

/************************************/
/* Total_By_Edition (Ent and Std    */
/************************************/
WITH Total_By_Edition AS 
(
	SELECT DISTINCT 
		S.ServerName
		,CASE 
			WHEN LEFT(S.Edition,9) = 'Developer' THEN 'Developer'
			WHEN LEFT(S.Edition,10) = 'Enterprise' THEN 'Enterprise'
			WHEN LEFT(S.Edition,7) = 'Express' THEN 'Express'
			WHEN LEFT(S.Edition,8) = 'Standard' THEN 'Standard'
		END AS Edition
		,SL.Contact_Lost
	FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
	LEFT JOIN [DBS_DW].[dbo].[vw_Server_Latest] SL
		ON S.Windows_Server_id = SL.Windows_Server_id
	WHERE Contact_Lost = 0
	AND SL.Manufacturer = 'VMware, Inc.'
)
SELECT 
	Total_By_Edition.Edition
	,COUNT(1) AS Total_By_Edition
FROM Total_By_Edition

GROUP BY Total_By_Edition.Edition ;

/*******************/
/* Total_By_Role   */
/*******************/

WITH Total_By_Version_Edition AS 
(
	SELECT DISTINCT 
		S.ServerName
		,SR.Role
		,SL.Contact_Lost
	FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
	JOIN [dbo].[Server_Roles] SR
		ON s.ServerName = SR.ServerName
	LEFT JOIN [DBS_DW].[dbo].[vw_Server_Latest] SL
		ON S.Windows_Server_id = SL.Windows_Server_id
	WHERE Contact_Lost = 0
	AND SL.Manufacturer = 'VMware, Inc.'
)
SELECT 
	Total_By_Version_Edition.Role
	,COUNT(1) AS Total_By_Version_Role
FROM Total_By_Version_Edition
GROUP BY Total_By_Version_Edition.Role
ORDER BY Total_By_Version_Edition.Role;


/************************************/
/* Total_By_Role_Edition (Ent and Std    */
/************************************/

WITH Total_By_Version_Edition AS 
(
	SELECT DISTINCT 
		S.ServerName
		,SR.Role
		,CASE 
			WHEN LEFT(S.Edition,9) = 'Developer' THEN 'Developer'
			WHEN LEFT(S.Edition,10) = 'Enterprise' THEN 'Enterprise'
			WHEN LEFT(S.Edition,7) = 'Express' THEN 'Express'
			WHEN LEFT(S.Edition,8) = 'Standard' THEN 'Standard'
		END AS Edition
	FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
	JOIN [dbo].[Server_Roles] SR
		ON s.ServerName = SR.ServerName
	LEFT JOIN [DBS_DW].[dbo].[vw_Server_Latest] SL
		ON S.Windows_Server_id = SL.Windows_Server_id
	WHERE Contact_Lost = 0
	AND SL.Manufacturer = 'VMware, Inc.'
)
SELECT 
	Total_By_Version_Edition.Role
	,Total_By_Version_Edition.Edition
	,COUNT(1) AS Total_By_Version_Edition
FROM Total_By_Version_Edition
GROUP BY Total_By_Version_Edition.Role, Total_By_Version_Edition.Edition 
ORDER BY Total_By_Version_Edition.Role, Total_By_Version_Edition.Edition ;

/************************************/
/* Total_By_Version_Edition (Ent and Std    */
/************************************/
WITH Total_By_Version_Edition AS 
(
	SELECT DISTINCT 
		S.ServerName
		,CASE 
			WHEN LEFT(S.ProductVersion,2) = '8.' THEN 'SQL2000'
			WHEN LEFT(S.ProductVersion,2) = '9.' THEN 'SQL2005'
			WHEN LEFT(S.ProductVersion,4) = '10.0' THEN 'SQL2008'
			WHEN LEFT(S.ProductVersion,4) = '10.5' THEN 'SQL2008R2'
			WHEN LEFT(S.ProductVersion,2) = '11' THEN 'SQL2012'
			WHEN LEFT(S.ProductVersion,2) = '12' THEN 'SQL2014'
			WHEN LEFT(S.ProductVersion,2) = '13' THEN 'SQL2016'
		END AS [SQL_Version]
		,CASE 
			WHEN LEFT(S.Edition,9) = 'Developer' THEN 'Developer'
			WHEN LEFT(S.Edition,10) = 'Enterprise' THEN 'Enterprise'
			WHEN LEFT(S.Edition,7) = 'Express' THEN 'Express'
			WHEN LEFT(S.Edition,8) = 'Standard' THEN 'Standard'
		END AS Edition
	FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
	LEFT JOIN [DBS_DW].[dbo].[vw_Server_Latest] SL
		ON S.Windows_Server_id = SL.Windows_Server_id
	WHERE Contact_Lost = 0
	AND SL.Manufacturer = 'VMware, Inc.'
)
SELECT 
	Total_By_Version_Edition.SQL_Version
	,Total_By_Version_Edition.Edition
	,COUNT(1) AS Total_By_Version_Edition
FROM Total_By_Version_Edition
GROUP BY Total_By_Version_Edition.SQL_Version, Total_By_Version_Edition.Edition ;

/************************************/
/* Match VM to Host                  */
/************************************/

;WITH Total_By_Edition AS 
(
	SELECT DISTINCT 
		SL.Server_Name
		,S.ServerName
		,CASE 
			WHEN LEFT(S.Edition,9) = 'Developer' THEN 'Developer'
			WHEN LEFT(S.Edition,10) = 'Enterprise' THEN 'Enterprise'
			WHEN LEFT(S.Edition,7) = 'Express' THEN 'Express'
			WHEN LEFT(S.Edition,8) = 'Standard' THEN 'Standard'
		END AS Edition
		,SL.Contact_Lost
	FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
	LEFT JOIN [DBS_DW].[dbo].[vw_Server_Latest] SL
		ON S.Windows_Server_id = SL.Windows_Server_id
	WHERE SL.Manufacturer = 'VMware, Inc.'
)
SELECT 
	T.Server_Name
	,T.Edition
	,VM.DataCentre
	,VM.VMVersion
	,VM.VMHost
	,vm.[DataCentre_VMVersion]
FROM Total_By_Edition T
JOIN [dbo].[VMWare_VMs] VM
	ON VM.VMServerName = T.Server_Name
ORDER BY T.Server_Name




