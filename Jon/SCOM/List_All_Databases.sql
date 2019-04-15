SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DISTINCT 
	ME.[Path] AS [Full_SQL_Server]
	,CASE 
		WHEN ME2.Name = 'MSSQLSERVER' THEN UPPER(LEFT(ME.[Path],CHARINDEX('.',ME.[Path])-1))
		ELSE UPPER(LEFT(ME.[Path],CHARINDEX('.',ME.[Path])-1) + '\' + ME2.Name)
		END AS [SQL_Server]
	,ME2.Name AS [Instance_Name]
	,ME.[DisplayName] AS [Database_Name]

FROM [dbo].[vManagedEntity] ME
JOIN (
	SELECT [TopLevelHostManagedEntityRowId], [Path], [Name]
	FROM [dbo].[vManagedEntity] ME
	JOIN [OperationsManagerDW].[dbo].[vManagedEntityType] MET
		ON ME.ManagedEntityTypeRowId = MET.ManagedEntityTypeRowId
	WHERE MET.ManagedEntityTypeSystemName LIKE '%DBEngine%'
	) ME2
	ON ME.TopLevelHostManagedEntityRowId = me2.TopLevelHostManagedEntityRowId
WHERE ME.ManagedEntityTypeRowId = 1234
--AND ME.TopLevelHostManagedEntityRowId = 2517
ORDER BY ME.[Path], ME.[DisplayName]

--3764