WITH SQL_Version AS 
(
	SELECT [ServerName]
      ,[ProductVersion]
	  ,	CASE 
		WHEN LEFT(ProductVersion,2) = '8.' THEN 'SQL2000'
		WHEN LEFT(ProductVersion,2) = '9.' THEN 'SQL2005'
		WHEN LEFT(ProductVersion,4) = '10.0' THEN 'SQL2008'
		WHEN LEFT(ProductVersion,4) = '10.5' THEN 'SQL2008R2'
		WHEN LEFT(ProductVersion,2) = '11' THEN 'SQL2012'
		WHEN LEFT(ProductVersion,2) = '12' THEN 'SQL2014'
		WHEN LEFT(ProductVersion,2) = '13' THEN 'SQL2016'
	END AS [SQL_Version]
	FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest]
)

SELECT S.[ServerName]
      ,S.[ProductVersion] AS CURRENT_VERSION
	  ,L.ProductVersion
	  ,	V.SQL_Version
	  ,SQL_Upgrade_Required = (CASE WHEN CONVERT(INT,REPLACE(S.[ProductVersion],'.','')) < CONVERT(INT,REPLACE(L.ProductVersion,'.','')) THEN 'Yes' ELSE 'No' END)
FROM [DBS_DW].[dbo].[vw_SQL_Servers_Latest] S
JOIN SQL_Version V 
	ON S.ServerName = V.ServerName
LEFT JOIN Service_Pack_Review.dbo.ProductVersions L
	ON V.[SQL_Version] = L.Product
LEFT JOIN Service_Pack_Review.dbo.ServicePack_Upgrade_Restricted_Servers R
	ON S.ServerName = R.ServerName

WHERE (CASE WHEN CONVERT(INT,REPLACE(S.[ProductVersion],'.','')) < CONVERT(INT,REPLACE(L.ProductVersion,'.','')) THEN 'Yes' ELSE 'No' END) = 'yes'
AND R.ServicePackRestricted IS NULL
ORDER BY S.ServerName 
