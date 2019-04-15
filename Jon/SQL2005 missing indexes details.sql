/*------------------------------------------------
Index_Advantage limits:	
10,000	this can increase performance but must be balanced against impact
50,000 this increase in performance far outweighs any overhead

To create the new indexes the equality_columns make up the first element 
and the inequality_columns make up the second and then the include_columns e.g.

CREATE NONCLUSTERED INDEX <index_name>
     ON <table_name> (<equality_columns (comma spearated)>,<inequality_columns (comma spearated)>)
     INCLUDE (<included_columns (comma spearated)>);
------------------------------------------------*/

WITH QUERY1 AS
(
	SELECT CONVERT(BIGINT,(gs.user_seeks * gs.avg_total_user_cost * (gs.avg_user_impact * 0.01))) AS INDEX_ADVANTAGE
	,d.statement as FULLY_QUALIFIED_OBJECT
	,DB_NAME(d.database_id) DBNAME
	,SUBSTRING(	d.statement, LEN(d.statement)-CHARINDEX('[',REVERSE(d.statement))+1, LEN(d.statement)- (LEN(d.statement)-CHARINDEX('[',REVERSE(d.statement)))) as TABLE_NAME
	,d.index_handle
	,g.index_group_handle
	,d.equality_columns
	,d.inequality_columns
	,d.included_columns
	,gs.*
	FROM sys.dm_db_missing_index_details d 
	INNER JOIN sys.dm_db_missing_index_groups AS g 
		ON g.index_handle = d.index_handle
	INNER JOIN sys.dm_db_missing_index_group_stats gs 
		on gs.group_handle = g.index_group_handle
	WHERE db_name(d.database_id)  NOT IN ('master','tempdb','msdb','model')
)
SELECT *
,
	'USE ' + DBNAME + '; IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'''+SUBSTRING(FULLY_QUALIFIED_OBJECT,CHARINDEX('.',FULLY_QUALIFIED_OBJECT)+1,LEN(FULLY_QUALIFIED_OBJECT)-CHARINDEX('.',FULLY_QUALIFIED_OBJECT)) +''') AND name = ''<INDEX_NAME>'') CREATE NONCLUSTERED INDEX [<INDEX_NAME>] ON '+
	SUBSTRING(FULLY_QUALIFIED_OBJECT,CHARINDEX('.',FULLY_QUALIFIED_OBJECT)+1,LEN(FULLY_QUALIFIED_OBJECT)-CHARINDEX('.',FULLY_QUALIFIED_OBJECT))	+' (' 
	+ 
	CASE 
		WHEN EQUALITY_COLUMNS IS NOT NULL AND INEQUALITY_COLUMNS IS NOT NULL AND INCLUDED_COLUMNS IS NOT NULL
			THEN EQUALITY_COLUMNS + ', ' + INEQUALITY_COLUMNS + ') INCLUDE (' + INCLUDED_COLUMNS + ')'
		WHEN EQUALITY_COLUMNS IS NOT NULL AND INEQUALITY_COLUMNS IS NOT NULL AND INCLUDED_COLUMNS IS NULL
			THEN EQUALITY_COLUMNS + ', ' + INEQUALITY_COLUMNS + ')'		
		WHEN EQUALITY_COLUMNS IS NOT NULL AND INEQUALITY_COLUMNS IS NULL AND INCLUDED_COLUMNS IS NOT NULL
			THEN EQUALITY_COLUMNS + ') INCLUDE (' + INCLUDED_COLUMNS + ')'
		WHEN EQUALITY_COLUMNS IS NOT NULL AND INEQUALITY_COLUMNS IS NULL AND INCLUDED_COLUMNS IS NULL
			THEN EQUALITY_COLUMNS + ')'
		WHEN EQUALITY_COLUMNS IS NULL AND INEQUALITY_COLUMNS IS NOT NULL AND INCLUDED_COLUMNS IS NOT NULL
			THEN INEQUALITY_COLUMNS + ') INCLUDE (' + INCLUDED_COLUMNS + ')'
		WHEN EQUALITY_COLUMNS IS NULL AND INEQUALITY_COLUMNS IS NOT NULL AND INCLUDED_COLUMNS IS NULL
			THEN INEQUALITY_COLUMNS + ')'
		END
	+
	' WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY];' AS INDEX_SCRIPT 
FROM QUERY1
WHERE INDEX_ADVANTAGE >10000
ORDER BY INDEX_ADVANTAGE DESC,DBNAME