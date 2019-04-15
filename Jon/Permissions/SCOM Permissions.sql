SET NOCOUNT ON;
DECLARE @SQL VARCHAR(MAX)
DECLARE @DBNAME VARCHAR(50)
DECLARE @LowPrivGroup VARCHAR(200) 
DECLARE @ActionGroup VARCHAR(200) 
DECLARE @PERMISSION VARCHAR(15)
DECLARE @READONLY TINYINT	
DECLARE @ITEM_COUNTER INT
DECLARE @LOOP_COUNTER INT
DECLARE @ITEM_TABLE TABLE (ID INT IDENTITY(1,1), DBNAME VARCHAR(50), is_read_only TINYINT)

SET @LowPrivGroup = 'PFG\SCOM_SQLLowPriv'
SET @ActionGroup = ''
SET @PERMISSION = 'db_datareader'
SET @SQL = ''

	EXEC ('USE master; IF NOT EXISTS(SELECT name FROM sys.syslogins WHERE name LIKE ''%'+@LowPrivGroup+''') BEGIN CREATE LOGIN ['+@LowPrivGroup+'] FROM WINDOWS WITH DEFAULT_DATABASE=[master] END')
                            
INSERT INTO @ITEM_TABLE (DBNAME, is_read_only)
SELECT name, is_read_only FROM SYS.DATABASES WHERE database_id > 4 AND source_database_id IS NULL ORDER BY name

SET @LOOP_COUNTER = (SELECT COUNT(1) FROM @ITEM_TABLE)
SET @ITEM_COUNTER = 1

WHILE @LOOP_COUNTER > 0 AND @ITEM_COUNTER <= @LOOP_COUNTER
BEGIN
	SELECT 
		@DBNAME = DBNAME,
		@READONLY = is_read_only
	FROM @ITEM_TABLE
	WHERE ID = @ITEM_COUNTER

	IF @READONLY = 1
	BEGIN 
		EXEC('ALTER DATABASE '+ @DBNAME + ' SET READ_WRITE WITH ROLLBACK IMMEDIATE;')
	END	



	EXEC ('USE ' + '[' + @DBNAME + '];IF EXISTS (SELECT name FROM [sys].[sysusers] WHERE name = '''+@LowPrivGroup+''') BEGIN EXEC sp_addrolemember N'''+@PERMISSION+''', N'''+@LowPrivGroup+''' END')
	EXEC ('USE ' + '[' + @DBNAME + '];IF NOT EXISTS (SELECT name FROM [sys].[sysusers] WHERE name = '''+@LowPrivGroup+''') BEGIN CREATE USER ['+@LowPrivGroup+'] FOR LOGIN ['+@LowPrivGroup+'] EXEC sp_addrolemember '''+@PERMISSION+''', '''+@LowPrivGroup+''' END')
	--EXEC ('USE ' + '[' + @DBNAME + ']; EXEC sp_addrolemember '''+@PERMISSION+''', '''+@LowPrivGroup+''' ')

	IF @READONLY = 1
	BEGIN 
		EXEC('ALTER DATABASE '+ @DBNAME + ' SET READ_ONLY;')
	END 

	SET @READONLY = 0
			
	SET @ITEM_COUNTER = @ITEM_COUNTER + 1

END


EXEC ('USE ' + '[msdb]; exec sp_addrolemember ''SQLAgentReaderRole'', ''' + @LowPrivGroup + ''';' )
--EXEC ('USE ' + '[msdb]; exec sp_addrolemember ''PolicyAdministratorRole'', ''' + @LowPrivGroup + ''';' )

---------------------------------------------------------------------------------
--IF @ActionGroup <> ''
--BEGIN
--	--DEFAULT ACTION ACCOUNT
--	EXEC ('USE ' + '[msdb]; GRANT VIEW ANY DEFINITION TO [' + @ActionGroup + '];' )
--	EXEC ('USE ' + '[msdb]; GRANT VIEW SERVER STATE TO [' + @ActionGroup + '];'  )
--	EXEC ('USE ' + '[msdb]; GRANT VIEW ANY DATABASE TO [' + @ActionGroup + '];')

--	--add msdb permissions
--	EXEC ('USE ' + '[msdb]; exec sp_addrolemember ''SQLAgentReaderRole'', ''' + @ActionGroup + ''';')
--	EXEC ('USE ' + '[msdb]; exec sp_addrolemember ''PolicyAdministratorRole'', ''' + @ActionGroup + ''';' )
--END
