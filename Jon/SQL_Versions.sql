USE [SQL_Licensing];
SET NOCOUNT ON

SELECT 
	UPPER(A.[ServerName]) AS ServerName
	,A.[Type]
	,A.[Instance]
	,A.[Edition]
	,A.[Product_Version]
	,A.[Full_Version]
	,B.Latest_Build
	,B.Latest_File_Version
	,CASE 
		WHEN A.[Full_Version] <> B.Latest_Build OR A.[Full_Version] <> B.Latest_File_Version THEN 'Not Patched'
		ELSE 'Patched'
	END AS [Patch_Status]
FROM [SQL_Licensing].[Results].[All_Matched_Instances] A
JOIN [SQL_Licensing].[dbo].[SQL_Versions] B
	ON 'SQL'+A.Product_Version = B.Product
WHERE Type = 'Microsoft SQL Server'
AND A.[Product_Version] = '2005'
AND CASE 
		WHEN A.[Full_Version] <> B.Latest_Build OR A.[Full_Version] <> B.Latest_File_Version THEN 'Not Patched'
		ELSE 'Patched'
	END = 'Not Patched' ;



WITH Patched AS 
(
SELECT 
	A.[Product_Version]
	,CASE 
		WHEN A.[Full_Version] <> B.Latest_Build OR A.[Full_Version] <> B.Latest_File_Version THEN 'Not Patched'
		ELSE 'Patched'
	END AS [Patch_Status]
FROM [SQL_Licensing].[Results].[All_Matched_Instances] A
JOIN [SQL_Licensing].[dbo].[SQL_Versions] B
	ON 'SQL'+A.Product_Version = B.Product
WHERE Type = 'Microsoft SQL Server'
AND CASE 
		WHEN A.[Full_Version] <> B.Latest_Build OR A.[Full_Version] <> B.Latest_File_Version THEN 'Not Patched'
		ELSE 'Patched'
	END = 'Not Patched'
)
SELECT 
	Product_Version
	,Patch_Status
	,COUNT(1) AS Total
FROM Patched
GROUP BY Product_Version,Patch_Status
