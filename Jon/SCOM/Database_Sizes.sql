SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT 
	PD.[DateTime]
	,PD.[PerformanceRuleInstanceRowId]
	,PD.[ManagedEntityRowId]
	,PD.[SampleCount]
	,PD.[AverageValue]
	,PD.[MinValue]
	,PD.[MaxValue]
	,PD.[StandardDeviation]
	,ME.[Path]
	,ME.[DisplayName]
	,PR.ObjectName
	,PR.CounterName
FROM [OperationsManagerDW].[Perf].[vPerfHourly] PD
JOIN [dbo].[vPerformanceRuleInstance] PRI
	ON PD.PerformanceRuleInstanceRowId = PRI.PerformanceRuleInstanceRowId
JOIN [dbo].[vPerformanceRule] PR
	ON PR.[RuleRowId] = PRI.RuleRowId
JOIN [dbo].[vManagedEntity] ME
	ON PD.ManagedEntityRowId = ME.ManagedEntityRowId
WHERE PR.CounterName = 'DB Allocated Size (MB)'
AND ME.TopLevelHostManagedEntityRowId = 5326
AND ME.ManagedEntityTypeRowId = 1234
ORDER BY  ME.[Path] , ME.[DisplayName], PD.[datetime] DESC

/************************************************/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH PerfHourly AS
(
	SELECT 
		MAX(DateTime) AS [DateTime]
		,ManagedEntityRowId
		,PerformanceRuleInstanceRowId
		,AverageValue 
		,MinValue
		,MaxValue
	FROM [Perf].[vPerfHourly]  
	WHERE datetime > DATEADD(MINUTE,-240,GETDATE()) 
	GROUP BY ManagedEntityRowId,PerformanceRuleInstanceRowId, AverageValue, MinValue, MaxValue
),
SQL_Servers AS 
(
	SELECT [TopLevelHostManagedEntityRowId], [Path], [Name]
	FROM [dbo].[vManagedEntity] ME
	JOIN [dbo].[vManagedEntityType] MET
		ON ME.ManagedEntityTypeRowId = MET.ManagedEntityTypeRowId
	WHERE MET.ManagedEntityTypeSystemName LIKE '%DBEngine%'
)


SELECT DISTINCT --TOP 100 
	ME.[Path] AS [Full_SQL_Server]
	,CASE 
		WHEN ME2.Name = 'MSSQLSERVER' THEN UPPER(LEFT(ME.[Path],CHARINDEX('.',ME.[Path])-1))
		ELSE UPPER(LEFT(ME.[Path],CHARINDEX('.',ME.[Path])-1) + '\' + ME2.Name)
		END AS [SQL_Server]
	,ME2.Name AS [Instance_Name]
	,ME.[DisplayName] AS [Database_Name]
	,PH.AverageValue
	,PH.MinValue
	,PH.MaxValue
	,PR.RuleRowId
	,PR.CounterName
	,ME.*
	
FROM [dbo].[vManagedEntity] ME
JOIN SQL_Servers ME2
	ON ME.TopLevelHostManagedEntityRowId = me2.TopLevelHostManagedEntityRowId
JOIN PerfHourly PH
	ON ME.ManagedEntityRowId = PH.ManagedEntityRowId

JOIN [dbo].[vPerformanceRuleInstance] PRI
	ON PH.PerformanceRuleInstanceRowId = PRI.PerformanceRuleInstanceRowId
JOIN [dbo].[vPerformanceRule] PR
	ON PR.[RuleRowId] = PRI.RuleRowId

WHERE ME.TopLevelHostManagedEntityRowId = 5326
AND ME.[DisplayName] = 'dbsadmin'
--AND PR.RuleRowId = 1363
--AND PR.CounterName = 'DB Used Space (MB)'
AND ME.ManagedEntityTypeRowId = 1234
ORDER BY ME.[DisplayName] --ME.[Path], ME.[DisplayName]

--3764


