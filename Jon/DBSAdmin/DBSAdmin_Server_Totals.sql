/*Count of all SQL servers*/
SELECT 
	COUNT(1) AS [Total_SQL_Servers]
FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest];

/*Count of all SQL Databases*/
WITH DIST_DB AS 
(
	SELECT 
		DISTINCT Server_Name, name AS [Total_Databases]
	FROM [DBS_DW].[dbo].[vw_SQL_Database_Latest]
		WHERE lastobserved > DATEADD (DAY,-5,GETDATE())
)
SELECT COUNT(1) FROM DIST_DB;

/*SQL server counts by usage*/
SELECT 
	CASE 
		WHEN RS.[description] LIKE '%TEST%' THEN 'Test Server' 
		WHEN RS.[description] IS NULL THEN 'Unknown' 
		ELSE 'Production Server' 
	END AS [Server_Usage]
	,COUNT(1) AS [Total_Databases]
FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] SS
LEFT JOIN [msdb].[dbo].[sysmanagement_shared_registered_servers_internal] RS
	ON SS.ServerName = RS.name
GROUP BY 
	CASE 
		WHEN RS.[description] LIKE '%TEST%' THEN 'Test Server' 
		WHEN RS.[description] IS NULL THEN 'Unknown' 
		ELSE 'Production Server' 
	END 

/*Count by SQL version*/
SELECT 
	CASE 
		WHEN LEFT(ProductVersion,2) = '8.' THEN 'SQL2000'
		WHEN LEFT(ProductVersion,2) = '9.' THEN 'SQL2005'
		WHEN LEFT(ProductVersion,4) = '10.0' THEN 'SQL2008'
		WHEN LEFT(ProductVersion,4) = '10.5' THEN 'SQL2008R2'
		WHEN LEFT(ProductVersion,2) = '11' THEN 'SQL2012'
		WHEN LEFT(ProductVersion,2) = '12' THEN 'SQL2014'
		WHEN LEFT(ProductVersion,2) = '13' THEN 'SQL2016'
	END AS [SQL_Version]
	,COUNT(1) AS [Total_Servers]
FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] SS
LEFT JOIN [msdb].[dbo].[sysmanagement_shared_registered_servers_internal] RS
	ON SS.ServerName = RS.name
GROUP BY 
	CASE 
		WHEN LEFT(ProductVersion,2) = '8.' THEN 'SQL2000'
		WHEN LEFT(ProductVersion,2) = '9.' THEN 'SQL2005'
		WHEN LEFT(ProductVersion,4) = '10.0' THEN 'SQL2008'
		WHEN LEFT(ProductVersion,4) = '10.5' THEN 'SQL2008R2'
		WHEN LEFT(ProductVersion,2) = '11' THEN 'SQL2012'
		WHEN LEFT(ProductVersion,2) = '12' THEN 'SQL2014'
		WHEN LEFT(ProductVersion,2) = '13' THEN 'SQL2016'
	END 


/* Distinct Server list*/
SELECT DISTINCT
	[ServerName]
	,CASE 
		WHEN LEFT(ProductVersion,2) = '8.' THEN 'SQL2000'
		WHEN LEFT(ProductVersion,2) = '9.' THEN 'SQL2005'
		WHEN LEFT(ProductVersion,4) = '10.0' THEN 'SQL2008'
		WHEN LEFT(ProductVersion,4) = '10.5' THEN 'SQL2008R2'
		WHEN LEFT(ProductVersion,2) = '11' THEN 'SQL2012'
		WHEN LEFT(ProductVersion,2) = '12' THEN 'SQL2014'
		WHEN LEFT(ProductVersion,2) = '13' THEN 'SQL2016'
		WHEN LEFT(ProductVersion,2) = '13' THEN 'SQL2016'
	END AS [SQL_Version]
	,RS.[description]
	,CASE 
		WHEN RS.[description] LIKE '%TEST%' THEN 'Test Server' 
		WHEN RS.[description] IS NULL THEN 'Unknown' 
		ELSE 'Production Server' 
	END AS [Server_Usage]
FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] SS
LEFT JOIN [msdb].[dbo].[sysmanagement_shared_registered_servers_internal] RS
	ON SS.ServerName = RS.name


/*Distinct database list by server*/
SELECT DISTINCT
	SS.[ServerName]
	,CASE 
		WHEN LEFT(SS.ProductVersion,2) = '8.' THEN 'SQL2000'
		WHEN LEFT(SS.ProductVersion,2) = '9.' THEN 'SQL2005'
		WHEN LEFT(SS.ProductVersion,4) = '10.0' THEN 'SQL2008'
		WHEN LEFT(SS.ProductVersion,4) = '10.5' THEN 'SQL2008R2'
		WHEN LEFT(SS.ProductVersion,2) = '11' THEN 'SQL2012'
		WHEN LEFT(SS.ProductVersion,2) = '12' THEN 'SQL2014'
		WHEN LEFT(SS.ProductVersion,2) = '13' THEN 'SQL2016'
		WHEN LEFT(SS.ProductVersion,2) = '13' THEN 'SQL2016'
	END AS [SQL_Version]
	,D.name AS [Database_Name]
	,RS.[description]
	,CASE 
		WHEN RS.[description] LIKE '%TEST%' THEN 'Test Server' 
		WHEN RS.[description] IS NULL THEN 'Unknown' 
		ELSE 'Production Server' 
	END AS [Server_Usage]
FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] SS
left JOIN [DBS_DW].[dbo].[vw_SQL_Database_Latest] D
	ON SS.MonitoredItem_GUID = D.MonitoredItem_GUID
LEFT JOIN [msdb].[dbo].[sysmanagement_shared_registered_servers_internal] RS
	ON SS.ServerName = RS.name



/*Count by SQL version*/
SELECT DISTINCT	
	CASE 
		WHEN LEFT(ProductVersion,2) = '8.' THEN 'SQL2000'
		WHEN LEFT(ProductVersion,2) = '9.' THEN 'SQL2005'
		WHEN LEFT(ProductVersion,4) = '10.0' THEN 'SQL2008'
		WHEN LEFT(ProductVersion,4) = '10.5' THEN 'SQL2008R2'
		WHEN LEFT(ProductVersion,2) = '11' THEN 'SQL2012'
		WHEN LEFT(ProductVersion,2) = '12' THEN 'SQL2014'
		WHEN LEFT(ProductVersion,2) = '13' THEN 'SQL2016'
	END AS [SQL_Version]
	,CASE 
		WHEN RS.[description] LIKE '%TEST%' THEN 'Test Server' 
		WHEN RS.[description] IS NULL THEN 'Unknown' 
		ELSE 'Production Server' 
	END AS [Server_Usage]
	,COUNT(1) AS [Total_Databases]
FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] SS
JOIN [DBS_DW].[dbo].[vw_SQL_Database_Latest] D
	ON SS.MonitoredItem_GUID = D.MonitoredItem_GUID
LEFT JOIN [msdb].[dbo].[sysmanagement_shared_registered_servers_internal] RS
	ON SS.ServerName = RS.name
WHERE D.name IS NOT NULL	
GROUP BY 
	CASE 
		WHEN LEFT(ProductVersion,2) = '8.' THEN 'SQL2000'
		WHEN LEFT(ProductVersion,2) = '9.' THEN 'SQL2005'
		WHEN LEFT(ProductVersion,4) = '10.0' THEN 'SQL2008'
		WHEN LEFT(ProductVersion,4) = '10.5' THEN 'SQL2008R2'
		WHEN LEFT(ProductVersion,2) = '11' THEN 'SQL2012'
		WHEN LEFT(ProductVersion,2) = '12' THEN 'SQL2014'
		WHEN LEFT(ProductVersion,2) = '13' THEN 'SQL2016'
	END 
	,CASE 
		WHEN RS.[description] LIKE '%TEST%' THEN 'Test Server' 
		WHEN RS.[description] IS NULL THEN 'Unknown' 
		ELSE 'Production Server' 
	END 

/*Distinct database list by server (raw data)*/
SELECT 
	d.[name]
	, [database_id]
	, MAX([Effective_From_Date]) [Effective_From_Date]
	, MAX([LastObserved]) [LastObserved]
	, [ServerName]
	,CASE 
		WHEN RS.[description] LIKE '%TEST%' THEN 'Test Server' 
		WHEN RS.[description] IS NULL THEN 'Unknown' 
		ELSE 'Production Server' 
		END AS [Server_Usage]
FROM [SQLServer].[Databases] d
LEFT OUTER JOIN 
(
    select CONVERT(VARCHAR(MAX),[MonitoredItem_GUID]) [MonitoredItem_GUID]
        , Connection_Address [ServerName]
    from dbs_scheduler.[action].[target]
    GROUP BY CONVERT(VARCHAR(MAX),[MonitoredItem_GUID]), Connection_Address
) AS SQL_Servers
	ON d.[MonitoredItem_GUID] = sql_servers.[MonitoredItem_GUID]
LEFT JOIN [msdb].[dbo].[sysmanagement_shared_registered_servers_internal] RS
	ON SQL_Servers.ServerName = RS.name

WHERE source_database_id is null
AND [LastObserved] > DATEADD(DAY, -5, GETDATE())
--AND d.name NOT IN ('master','msdb','model','tempdb')
GROUP BY d.[name]
              ,[database_id]
              , [ServerName]
			  ,RS.[description]

/*Count of all SQL Databases (raw data)*/
SELECT count(1) FROM 
(
SELECT 
	d.[name]
	, [database_id]
	, MAX([Effective_From_Date]) [Effective_From_Date]
	, MAX([LastObserved]) [LastObserved]
	, [ServerName]
	,CASE 
		WHEN RS.[description] LIKE '%TEST%' THEN 'Test Server' 
		WHEN RS.[description] IS NULL THEN 'Unknown' 
		ELSE 'Production Server' 
		END AS [Server_Usage]
FROM [SQLServer].[Databases] d
LEFT OUTER JOIN 
(
    select CONVERT(VARCHAR(MAX),[MonitoredItem_GUID]) [MonitoredItem_GUID]
        , Connection_Address [ServerName]
    from dbs_scheduler.[action].[target]
    GROUP BY CONVERT(VARCHAR(MAX),[MonitoredItem_GUID]), Connection_Address
) AS SQL_Servers
	ON d.[MonitoredItem_GUID] = sql_servers.[MonitoredItem_GUID]
LEFT JOIN [msdb].[dbo].[sysmanagement_shared_registered_servers_internal] RS
	ON SQL_Servers.ServerName = RS.name

WHERE source_database_id is null
       AND [LastObserved] > DATEADD(DAY, -5, GETDATE())
GROUP BY d.[name]
              ,[database_id]
              , [ServerName]
			  ,RS.[description]

) a

/*Database counts by usage (raw data)*/

SELECT [Server_Usage], COUNT(1) FROM 
(
SELECT 
	d.[name]
	, [database_id]
	, MAX([Effective_From_Date]) [Effective_From_Date]
	, MAX([LastObserved]) [LastObserved]
	, [ServerName]
	,CASE 
		WHEN RS.[description] LIKE '%TEST%' THEN 'Test Server' 
		WHEN RS.[description] IS NULL THEN 'Unknown' 
		ELSE 'Production Server' 
		END AS [Server_Usage]
FROM [SQLServer].[Databases] d
LEFT OUTER JOIN 
(
    select CONVERT(VARCHAR(MAX),[MonitoredItem_GUID]) [MonitoredItem_GUID]
        , Connection_Address [ServerName]
    from dbs_scheduler.[action].[target]
    GROUP BY CONVERT(VARCHAR(MAX),[MonitoredItem_GUID]), Connection_Address
) AS SQL_Servers
	ON d.[MonitoredItem_GUID] = sql_servers.[MonitoredItem_GUID]
LEFT JOIN [msdb].[dbo].[sysmanagement_shared_registered_servers_internal] RS
	ON SQL_Servers.ServerName = RS.name

WHERE source_database_id is null
       AND [LastObserved] > DATEADD(DAY, -5, GETDATE())
GROUP BY d.[name]
              ,[database_id]
              , [ServerName]
			  ,RS.[description]

) a
GROUP BY [Server_Usage]