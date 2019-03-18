WITH fs
AS
(
    SELECT database_id, type, size * 8.0 / 1024 size
    FROM sys.master_files
)
SELECT --top 10
    db.name,
    (SELECT CONVERT(DECIMAL(15,2),sum(size)) FROM fs WHERE type = 0 and fs.database_id = db.database_id) DataFileSizeMB,
    (SELECT CONVERT(DECIMAL(15,2),sum(size)) FROM fs WHERE type = 1 and fs.database_id = db.database_id) LogFileSizeMB,
	(SELECT CONVERT(DECIMAL(15,2),sum(size)) FROM fs WHERE type IN (0,1) and fs.database_id = db.database_id) TotalSizeMB,
	sdb.cmptlevel,
	db.create_date,
	db.state_desc,
	CASE WHEN db.is_read_only = 0 THEN 'READ_WRITE' ELSE 'READ_ONLY' END AS Updateability,
	db.user_access_desc,
	db.recovery_model_desc,
	db.collation_name
FROM sys.databases db
JOIN dbo.sysdatabases sdb
	ON db.database_id = sdb.dbid
WHERE database_id > 4
AND db.source_database_id IS NULL
ORDER BY DB.name--DataFileSizeMB DESC
