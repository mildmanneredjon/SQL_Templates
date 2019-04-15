DECLARE @TABLE1 TABLE 
(
[Name] SYSNAME,
[db_size1] VARCHAR(20),
[owner]    SYSNAME null,
[dbid]      INT,
[Created] DATETIME,
[Status]   VARCHAR(8000),
[Compatibility]     SMALLINT,
[DB_Size_MB] DECIMAL(15,2),
[DB_Size_GB] INT
)

INSERT INTO @TABLE1 ([Name],[db_size1],[owner],[dbid],[Created],[Status],[Compatibility])
EXEC sp_helpdb

--SELECT * FROM @TABLE1 WHERE [dbid] > 4 AND Name <> 'DBSAdmin'

UPDATE @TABLE1
SET [DB_Size_MB] = CONVERT(DECIMAL(15,2),REPLACE([db_size1],' MB',''))
,[DB_Size_GB] = CONVERT(DECIMAL(15,2),REPLACE([db_size1],' MB',''))/1024

SELECT 
	[Name], 
	[DB_Size_GB], 
	[DB_Size_MB], 
	[owner], 
	[dbid], 
	[Created], 
	[Status], 
	[Compatibility] 
FROM @TABLE1 WHERE [dbid] > 4 AND Name <> 'DBSAdmin'

/*
SELECT 
	count(1)
	,sum([DB_Size_GB])
FROM @TABLE1 WHERE [dbid] > 4 AND Name <> 'DBSAdmin'
*/