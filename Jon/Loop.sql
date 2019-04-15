use master
go
declare @table table (dbname varchar(20))
DECLARE @dbname sysname

insert into @table
select name from sysdatabases where name in ('PPS','PPS15','PPS2','GPS','GPS15','GPS2','PPCXLPAck','GPCXLPAck','HCXLPack')

while exists (select * from @table)
begin
	select 
		@dbname = dbname
	from @table

	--exec (N'use ' + N'[' + @dbname + N']; grant connect to misadmin')
	--exec (N'use ' + N'[' + @dbname + N']; exec sp_addrolemember ''db_owner'',''misadmin''')
	--exec (N'use ' + N'[' + @dbname + N']; exec sp_change_users_login "auto_fix",''misadmin''') 
	exec (N'use ' + N'[' + @dbname + N'];select * from sys.sysfiles')

delete from @table where dbname = @dbname
end

--*****************************************************************--
--*****************************************************************--
--Alternative
--*****************************************************************--
--*****************************************************************--


DECLARE @DBNAME VARCHAR(50)
DECLARE @ITEM_COUNTER INT
DECLARE @LOOP_COUNTER INT
DECLARE @TABLE1 TABLE (id INT IDENTITY(1,1),dbname VARCHAR(50))
                            
INSERT INTO @item_table (dbname)
SELECT name FROM sys.databases WHERE name in('master','msdb')

SET @LOOP_COUNTER = (SELECT COUNT(1) FROM @item_table)
SET @ITEM_COUNTER = 1

WHILE @LOOP_COUNTER > 0 AND @ITEM_COUNTER <= @LOOP_COUNTER
BEGIN

	SELECT 
		@DBNAME = dbname
	FROM @ITEM_TABLE
	WHERE id = @ITEM_COUNTER
	
	EXEC (N'use ' + N'[' + @dbname + N'];select * from sys.sysfiles')
	
	SET @ITEM_COUNTER = @ITEM_COUNTER + 1

END
