/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 
	PR.[DateTime]
	,PR.[PerformanceRuleInstanceRowId]
	,PR.[ManagedEntityRowId]
	,PR.[SampleValue]
FROM [OperationsManagerDW].[Perf].[vPerfRaw]PR
JOIN [dbo].[vPerformanceRuleInstance] PRI
	ON PR.PerformanceRuleInstanceRowId = PRI.PerformanceRuleInstanceRowId
WHERE ManagedEntityRowId = 2838
AND DateTime = (SELECT MAX(DateTime) FROM [OperationsManagerDW].[Perf].[vPerfRaw] WHERE ManagedEntityRowId = 2838)
AND PRI.InstanceName <> ''

SELECT * FROM [dbo].[vPerformanceRuleInstance] WHERE PerformanceRuleInstanceRowId IN (501,600,601)

SELECT * FROM [dbo].[vPerformanceRule] WHERE CounterName = 'DB Allocated Size (MB)'

SELECT * FROM [dbo].[vManagedEntity] WHERE ManagedEntityRowId = 2838

SELECT TOP 100 * FROM [Perf].[vPerfHourly] WHERE ManagedEntityRowId = 2838 ORDER BY DateTime desc

SELECT MAX([DateTime]) AS [DateTime], ManagedEntityRowId FROM [Perf].[vPerfHourly]  GROUP BY ManagedEntityRowId

SELECT * FROM [dbo].[vPerformanceRule]  WHERE ObjectName LIKE '%SQL%' ORDER BY CounterName
--DB Allocated Space (MB)


SELECT     
Perf.vPerfHourly.AverageValue, 
dbo.vPerformanceRuleInstance.InstanceName, 
dbo.vPerformanceRule.ObjectName, 
dbo.vPerformanceRule.CounterName,                       
dbo.vPerformanceRuleInstance.LastReceivedDateTime, 
Perf.vPerfHourly.DateTime, 
dbo.vManagedEntity.DWCreatedDateTime, 
dbo.vManagedEntity.ManagedEntityGuid, 
dbo.vManagedEntity.ManagedEntityDefaultName, 
dbo.vManagedEntity.DisplayName, 
dbo.vManagedEntity.Name, 
dbo.vManagedEntity.Path, 
dbo.vManagedEntity.FullName
FROM Perf.vPerfHourly 
INNER JOIN dbo.vPerformanceRuleInstance 
	ON Perf.vPerfHourly.PerformanceRuleInstanceRowId = dbo.vPerformanceRuleInstance.PerformanceRuleInstanceRowId 
INNER JOIN dbo.vManagedEntity 
	ON Perf.vPerfHourly.ManagedEntityRowId = dbo.vManagedEntity.ManagedEntityRowId 
INNER JOIN dbo.vPerformanceRule 
	ON dbo.vPerformanceRuleInstance.RuleRowId = dbo.vPerformanceRule.RuleRowId
WHERE (dbo.vPerformanceRule.ObjectName = 'Logicaldisk')
