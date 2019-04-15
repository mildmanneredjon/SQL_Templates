SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT 
	CS.[Statement_Customer_Id]
    ,CS.[Batch_Id]
    ,B.[File_Production_Date]
    ,AGR.[Agreement_Id]
    ,CS.[Statement_Type]
    ,CS.[Original_Source_Type_Id]
    ,CS.[Original_Customer_Identifier]
    ,CS.[Reference_Number]
    ,CS.[Customer_Number]
    ,CS.[Company_Code]
    ,CS.[Title]
    ,CS.[Forename]
    ,CS.[Surname]
    ,CS.[Address_Line_1]
    ,CS.[Address_Line_2]
    ,CS.[Address_Line_3]
    ,CS.[Address_Line_4]
    ,CS.[Postcode]
    ,CS.[Agency_Id]
    ,CS.[Managed_By_Role_Id]
    ,CS.[Managed_By_Role_Db_Id]
    ,CS.[Representative_Id]
    ,CS.[Dm_Name]
    ,CS.[Dm_Home_Telephone_Number]
    ,CS.[Dm_Mobile_Telephone_Number]
    ,CS.[Location_Id]
    ,CS.[Location_Db_Id]
    ,CS.[Office_Location_Name]
    ,CS.[Office_Address_Line_1]
    ,CS.[Office_Address_Line_2]
    ,CS.[Office_Address_Line_3]
    ,CS.[Office_Address_Line_4]
    ,CS.[Office_Postcode]
    ,CS.[Office_Tel_Num]
    ,CS.[Outstanding_Loan_Count]
    ,CS.[Total_Outstanding_Balance]
    ,CS.[Total_Weekly_Payment]
    ,CS.[Last_Creation_Date]
    ,CS.[Last_Updated_Date]
    ,CS.[Untraceable_Date]
    ,CS.[Rapid_Extract_Set_Num]
FROM [DW_Compliance_Mart].[EDW_DBO].[DM_STATEMENT_CUSTOMER] CS
JOIN [DW_Compliance_Mart].[EDW_DBO].[DM_STATEMENT_CONFIG] B
ON B.[Batch_Id] = CS.[Batch_Id]
JOIN [DW_Compliance_Mart].[EDW_DBO].[DM_STATEMENT_AGREEMENT] AGR
ON AGR.[Batch_Id] = CS.[Batch_Id]
AND AGR.[Statement_Customer_Id] = CS.[Statement_Customer_Id]
--WHERE [Original_Customer_Identifier] = 402785031
--WHERE CS.Customer_Number = 'F13001135202'
WHERE B.Batch_Id = 25037
ORDER BY CS.Batch_Id DESC
