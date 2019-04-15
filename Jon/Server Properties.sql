/* Declare Temp Tables */
CREATE TABLE #SVer(ID int,  Name  sysname, Internal_Value int, Value nvarchar(512))
INSERT #SVer EXEC master.dbo.xp_msver

EXEC sp_configure 'show advanced options',1
RECONFIGURE
CREATE TABLE #SMem([Name] VARCHAR(100), Minimum INT, Maximum BIGINT, ConfigValue BIGINT, RunValue BIGINT)
INSERT #SMem EXEC sp_configure 'max server memory (MB)'
EXEC sp_configure 'show advanced options',0
RECONFIGURE


/* Declare Variables */
DECLARE @MasterPath NVARCHAR(512)
DECLARE @LogPath NVARCHAR(512)
DECLARE @ErrorLog NVARCHAR(512)
DECLARE @ErrorLogPath NVARCHAR(512)
DECLARE @SmoRoot NVARCHAR(512)

/*Set Variables */
SELECT @MasterPath=SUBSTRING(physical_name, 1, LEN(physical_name) - CHARINDEX('\', REVERSE(physical_name))) FROM master.sys.database_files WHERE name=N'master'
SELECT @LogPath=SUBSTRING(physical_name, 1, LEN(physical_name) - CHARINDEX('\', REVERSE(physical_name))) FROM master.sys.database_files WHERE name=N'mastlog'
SELECT @ErrorLog=CAST(SERVERPROPERTY(N'errorlogfilename') AS nvarchar(512))
SELECT @ErrorLogPath=SUBSTRING(@ErrorLog, 1, LEN(@ErrorLog) - CHARINDEX('\', REVERSE(@ErrorLog)))
EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\Setup', N'SQLPath', @SmoRoot OUTPUT

SELECT 
	SERVERPROPERTY('MachineName') AS [MachineName]
	,SERVERPROPERTY('InstanceName') AS [InstanceName]
	,SERVERPROPERTY('ServerName') AS [ServerName]
	,CONVERT(VARCHAR(20), SERVERPROPERTY('ProductVersion')) AS [SQLProductVersion]
	,CASE WHEN LEFT((SELECT CONVERT(VARCHAR(20),SERVERPROPERTY('ProductVersion'))),1) = '9' THEN 'SQL2005'	
		WHEN LEFT((SELECT CONVERT(VARCHAR(20),SERVERPROPERTY('ProductVersion'))),1) = '8' THEN 'SQL2000'
		WHEN LEFT((SELECT CONVERT(VARCHAR(20),SERVERPROPERTY('ProductVersion'))),4) = '10.0' THEN 'SQL2008'	
		WHEN LEFT((SELECT CONVERT(VARCHAR(20),SERVERPROPERTY('ProductVersion'))),4) = '10.5' THEN 'SQL2008 R2'	
		WHEN LEFT((SELECT CONVERT(VARCHAR(20),SERVERPROPERTY('ProductVersion'))),2) = '11' THEN 'SQL2012' 
		WHEN LEFT((SELECT CONVERT(VARCHAR(20),SERVERPROPERTY('ProductVersion'))),2) = '12' THEN 'SQL2014' 
		WHEN LEFT((SELECT CONVERT(VARCHAR(20),SERVERPROPERTY('ProductVersion'))),2) = '13' THEN 'SQL2016' 
		WHEN LEFT((SELECT CONVERT(VARCHAR(20),SERVERPROPERTY('ProductVersion'))),2) = '14' THEN 'SQL2017' 
		ELSE 'UNKNOWN' END AS [SQLProductVersion2]
	,SERVERPROPERTY('ProductLevel') AS [SQLProductLevel]
	,SERVERPROPERTY('Edition') AS [SQLProductEdition]
	,SERVERPROPERTY('EngineEdition') AS [EngineEdition]
	,SERVERPROPERTY('COLLATION') AS [ServerCollation]
	,(select Internal_Value from #SVer where Name = N'ProcessorCount') AS [Processors]
	,(SELECT Internal_Value FROM #SVer WHERE Name = N'PhysicalMemory') AS [PhysicalMemory]
	,(SELECT ConfigValue FROM #SMem) AS [SQLMemory]
	,@MasterPath AS [MasterDBPath]
	,@LogPath AS [MasterDBLogPath]
	,@ErrorLogPath AS [ErrorLogPath]
	,@SmoRoot AS [RootDirectory]
	,CONVERT(VARCHAR(128),(CASE WHEN (SERVERPROPERTY('IsClustered')) = 1 THEN 'YES' WHEN (SERVERPROPERTY('IsClustered')) = 0 THEN 'NO' 	ELSE 'UNKNOWN' END)) AS [IsClustered]
	,SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [NetBiosName]
	,SERVERPROPERTY('LicenseType') AS [LicenseType]
	,SERVERPROPERTY('BuildClrVersion') AS [BuildClrVersion]
	,SERVERPROPERTY('IsIntegratedSecurityOnly') AS [IsIntegratedSecurityOnly]
	,SERVERPROPERTY('IsSingleUser') AS [IsSingleUser]
	,SERVERPROPERTY('ProcessID') AS [ProcessID]
	,CAST(case when 'a' <> 'A' then 1 else 0 end AS bit) AS [IsCaseSensitive]

--,SERVERPROPERTY('')

DROP TABLE #SVer
DROP TABLE #SMem