SELECT DISTINCT  
	I.Instance
	,D.DBName
	,T.TName 
	,C.[ColName]
	,C.DataType
FROM [SQL_Licensing].[ADDM].[SQL_Columns] C
JOIN [ADDM].[SQL_Tables] T
	ON C.TID = T.ID
JOIN [ADDM].[SQL_Databases] D
	ON T.DID = D.ID
JOIN [ADDM].[SQL_Instances_Exploration] I
	ON D.SID = I.ID