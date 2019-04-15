/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) 
	[Batch_Id]
	,[Statement_Type]
	,[Start_Date]
	,[End_Date]
	,[File_Production_Date]
	,[File_Name]
	,[FOCUS_Status]
	,[BIS_Status]
	,[FOCUS_Agreement_Count]
	,[BIS_Agreement_Count]
	,[FOCUS_Customer_Count]
	,[BIS_Customer_Count]
	,[Processed_Status]
	,[Last_Creation_Date]
	,[Last_Updated_Date]
	,[PRA_Status]
	,[PRA_Agreement_Count]
	,[PRA_Customer_Count]
	,[Accounting_Week]
FROM [DW_Compliance_Mart].[EDW_DBO].[DM_STATEMENT_CONFIG]
WHERE Batch_Id > 25030
ORDER BY  Batch_Id DESC