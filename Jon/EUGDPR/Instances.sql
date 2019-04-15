SELECT DISTINCT 
	[ID]
	,UPPER([ServerName]) AS ServerName
	,UPPER([Instance]) AS Instance
	,[Product_Version]
	,[ConnStr]
	,UPPER([Domain]) AS Domain
FROM [SQL_Licensing].[ADDM].[SQL_Instances_Exploration]
ORDER BY Instance 