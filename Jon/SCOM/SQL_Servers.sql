SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

/*Distint Windows Server with SQL Installed*/
SELECT DISTINCT
	me.[Path]
	--,me.TopLevelHostManagedEntityRowId
FROM [OperationsManagerDW].[dbo].[vManagedEntity] ME
JOIN [OperationsManagerDW].[dbo].[vManagedEntityType] MET
	ON me.ManagedEntityTypeRowId = MET.ManagedEntityTypeRowId
WHERE MET.ManagedEntityTypeSystemName LIKE '%DBEngine%'
ORDER BY me.Path	

/*All SQL Servers*/
SELECT DISTINCT
	ME.[Path] AS [Server_Name]
	,CASE 
		WHEN ME.Name = 'MSSQLSERVER' THEN UPPER(LEFT(ME.[Path],CHARINDEX('.',ME.[Path])-1))
		ELSE UPPER(LEFT(ME.[Path],CHARINDEX('.',ME.[Path])-1) + '\' + ME.Name)
	END AS [SQL_Server]
	,ME.Name AS [Instance_Name]
	--,ME.TopLevelHostManagedEntityRowId
	,MET.[ManagedEntityTypeDefaultName] AS [SQL_Version]
	--,MET.[ManagedEntityTypeSystemName]
FROM [OperationsManagerDW].[dbo].[vManagedEntity] ME
JOIN [OperationsManagerDW].[dbo].[vManagedEntityType] MET
	ON me.ManagedEntityTypeRowId = MET.ManagedEntityTypeRowId
WHERE MET.ManagedEntityTypeSystemName LIKE '%DBEngine%'
ORDER BY me.Path

/*SQL Servers by Version*/
SELECT DISTINCT
	COUNT(1) AS [Volume]
FROM [OperationsManagerDW].[dbo].[vManagedEntity] ME
JOIN [OperationsManagerDW].[dbo].[vManagedEntityType] MET
	ON me.ManagedEntityTypeRowId = MET.ManagedEntityTypeRowId
WHERE MET.ManagedEntityTypeSystemName LIKE '%DBEngine%'


/*SQL Servers by Version*/
SELECT DISTINCT
	MET.[ManagedEntityTypeDefaultName] AS [SQL_Version]
	,COUNT(1) AS [Volume]
FROM [OperationsManagerDW].[dbo].[vManagedEntity] ME
JOIN [OperationsManagerDW].[dbo].[vManagedEntityType] MET
	ON me.ManagedEntityTypeRowId = MET.ManagedEntityTypeRowId
WHERE MET.ManagedEntityTypeSystemName LIKE '%DBEngine%'
GROUP BY MET.[ManagedEntityTypeDefaultName]
