USE Field_Security_Database;

DECLARE @user VARCHAR(30) 
SET @user = 'HO\ggPortalFS_DSM_SASM_C'

CREATE ROLE db_executor;

GRANT EXECUTE TO db_executor;

EXEC sp_addrolemember N'db_executor', @user;


