
SELECT * 
FROM dbo.[Application]
WHERE DecisionReference =  '000016929993'

SELECT * 
FROM dbo.Application src -- WHERE  src.ApplicationID = 11029932
JOIN CHANGETABLE(CHANGES dbo.Application, 0) ct 
	ON src.ApplicationId = ct.ApplicationId 
WHERE ((ct.SYS_CHANGE_OPERATION ='I') OR
(ct.SYS_CHANGE_OPERATION = 'U')  )
and src.ApplicationID = 11029932
--AND DecisionReference = '000016929993'

SELECT * 
FROM dbo.[Application]
WHERE DecisionReference =  '000016929993'


SELECT 
*
,AgreementReference_Changed = CHANGE_TRACKING_IS_COLUMN_IN_MASK
    (COLUMNPROPERTY(OBJECT_ID('dbo.Application'), 'AgreementReference', 'ColumnId'),ct.sys_change_columns)
FROM CHANGETABLE(CHANGES dbo.Application, 0) ct 
WHERE ApplicationID = 11029932
--WHERE SYS_CHANGE_OPERATION = 'U'

SELECT COUNT(*), SYS_CHANGE_OPERATION FROM CHANGETABLE(CHANGES dbo.Application, 0) ct GROUP BY SYS_CHANGE_OPERATION


SELECT 
	OBJECT_NAME(object_id) AS _name
	,*
FROM sys.change_tracking_tables

SELECT sys.schemas.name as Schema_name
	, sys.tables.name as Table_name 
from sys.change_tracking_tables
join sys.tables on sys.tables.object_id = sys.change_tracking_tables.object_id
join sys.schemas on sys.schemas.schema_id = sys.tables.schema_id 
