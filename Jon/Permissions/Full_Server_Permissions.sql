DECLARE @DATABASE VARCHAR(40)
DECLARE @TABLE TABLE (DBNAME VARCHAR(100))
DECLARE @TABLE2 TABLE (
	[Database_Name] [nvarchar](128) NULL,
	[UserName] [nvarchar](128) NULL,
	[UserType] [varchar](12) NULL,
	[DatabaseUserName] [sysname] NULL,
	[Role] [sysname] NULL,
	[PermissionType] [nvarchar](128) NULL,
	[PermissionState] [nvarchar](60) NULL,
	[ObjectType] [nvarchar](60) NULL,
	[ObjectName] [nvarchar](128) NULL,
	[ColumnName] [sysname] NULL
	)

INSERT INTO @TABLE 
	SELECT [NAME] FROM SYS.DATABASES WHERE NAME NOT LIKE '%SNAPSHOT%'

WHILE EXISTS (SELECT * FROM @TABLE)
BEGIN

	SELECT @DATABASE = DBNAME FROM @TABLE

	INSERT INTO @TABLE2
		( Database_Name ,
			UserName ,
			UserType ,
			DatabaseUserName ,
			Role ,
			PermissionType ,
			PermissionState ,
			ObjectType ,
			ObjectName ,
			ColumnName
		)

	EXECUTE (N'USE [' + @DATABASE + N']; 
	WITH SQL1 AS
	(
		SELECT DB_NAME() AS Database_Name
			   , CASE princ.[type] 
							 WHEN ''S'' THEN princ.[name]
							 WHEN ''U'' THEN ulogin.[name] COLLATE Latin1_General_CI_AI
					  END [UserName]
			, CASE princ.[type]
							 WHEN ''S'' THEN ''SQL User''
							 WHEN ''U'' THEN ''Windows User''
					  END [UserType] 
			, princ.[name] [DatabaseUserName]      
			, null [Role]     
			, perm.[permission_name] [PermissionType]      
			, perm.[state_desc] [PermissionState]       
			, obj.type_desc [ObjectType]    
			, OBJECT_NAME(perm.major_id) [ObjectName]
			, col.[name] [ColumnName]
		FROM sys.database_principals princ  
			   LEFT JOIN sys.login_token ulogin 
					  ON princ.[sid] = ulogin.[sid]
			   LEFT JOIN sys.database_permissions perm 
					  ON perm.[grantee_principal_id] = princ.[principal_id]
			   LEFT JOIN sys.columns col 
					  ON col.[object_id] = perm.major_id 
							 AND col.[column_id] = perm.[minor_id]
			   LEFT JOIN sys.objects obj ON perm.[major_id] = obj.[object_id]
		WHERE princ.[type] in (''S'',''U'')
	)
	/************************************************/
	,SQL2 AS 
	(
		SELECT DB_NAME() AS Database_Name
			   , [UserName] = CASE memberprinc.[type] 
							 WHEN ''S'' THEN memberprinc.[name]
							 WHEN ''U'' THEN ulogin.[name] COLLATE Latin1_General_CI_AI
					  END
			, [UserType] = CASE memberprinc.[type]
							 WHEN ''S'' THEN ''SQL User''
							 WHEN ''U'' THEN ''Windows User''
					  END 
			, [DatabaseUserName] = memberprinc.[name]   
			, [Role] = roleprinc.[name]      
			, [PermissionType] = perm.[permission_name]       
			, [PermissionState] = perm.[state_desc]       
			, [ObjectType] = obj.type_desc 
			, [ObjectName] = OBJECT_NAME(perm.major_id)
			, [ColumnName] = col.[name]
		FROM sys.database_role_members members
			   JOIN sys.database_principals roleprinc 
					  ON roleprinc.[principal_id] = members.[role_principal_id]
			   JOIN sys.database_principals memberprinc 
					  ON memberprinc.[principal_id] = members.[member_principal_id]
			   LEFT JOIN sys.login_token ulogin 
					  on memberprinc.[sid] = ulogin.[sid]
			   LEFT JOIN sys.database_permissions perm 
					  ON perm.[grantee_principal_id] = roleprinc.[principal_id]
			   LEFT JOIN sys.columns col 
					  on col.[object_id] = perm.major_id 
							 AND col.[column_id] = perm.[minor_id]
			   LEFT JOIN sys.objects obj 
					  ON perm.[major_id] = obj.[object_id]
	)
	/*******************************************/
	,SQL3 AS 
	(
		SELECT  
			   DB_NAME() AS Database_Name
			, [UserName] = ''{All Users}''
			, [UserType] = ''{All Users}'' 
			, [DatabaseUserName] = ''{All Users}''       
			, [Role] = roleprinc.[name]      
			, [PermissionType] = perm.[permission_name]       
			, [PermissionState] = perm.[state_desc]       
			, [ObjectType] = obj.type_desc
			, [ObjectName] = OBJECT_NAME(perm.major_id)
			, [ColumnName] = col.[name]
		FROM sys.database_principals roleprinc
			   LEFT JOIN sys.database_permissions perm 
					  ON perm.[grantee_principal_id] = roleprinc.[principal_id]
			   LEFT JOIN sys.columns col 
					  on col.[object_id] = perm.major_id 
							 AND col.[column_id] = perm.[minor_id]                   
			   JOIN sys.objects obj 
					  ON obj.[object_id] = perm.[major_id]
		WHERE roleprinc.[type] = ''R'' 
			   AND roleprinc.[name] = ''public'' 
			   AND obj.is_ms_shipped = 0
	)

	SELECT 
		S1.Database_Name
		,S1.UserName
		,S1.UserType
		,S1.DatabaseUserName
		,S2.Role
		,S1.PermissionType
		,S1.PermissionState
		,S1.ObjectType
		,S1.ObjectName
		,S1.ColumnName
	FROM SQL1 S1
	LEFT JOIN SQL2 S2
		ON S1.Database_Name = S2.Database_Name
		AND S1.DatabaseUserName = S2.DatabaseUserName
	LEFT JOIN SQL3 S3
		ON S1.Database_Name = S3.Database_Name
		AND S1.DatabaseUserName = S3.DatabaseUserName'
	)

	DELETE FROM @TABLE WHERE DBNAME = @DATABASE

END

SELECT *
FROM @TABLE2
ORDER BY Database_Name, DatabaseUserName
