DECLARE @IP VARCHAR(20)
DECLARE @PortNumber VARCHAR(7)
DECLARE @Instance VARCHAR(50)
DECLARE @KKEY           VARCHAR(100)

SET @IP = (SELECT dec.local_net_address FROM sys.dm_exec_connections AS dec WHERE dec.session_id = @@SPID)
--SET @IP = (SELECT DISTINCT dec.local_net_address FROM sys.dm_exec_connections AS dec WHERE dec.local_net_address IS NOT NULL)

IF (SELECT CHARINDEX('\',(SELECT @@SERVERNAME)))=0
BEGIN
            SET @PortNumber= 1433
            GOTO Finish
END

SET @Instance= (SELECT SUBSTRING(@@SERVERNAME,CHARINDEX('\',@@SERVERNAME)+1,LEN(@@SERVERNAME)))
SET @KKEY='Software\Microsoft\Microsoft Sql Server\' + @Instance + '\MSSQLServer\SuperSocketNetLib\Tcp'

EXEC Xp_RegRead
@RootKey='HKEY_LOCAL_MACHINE',
@Key=@KKEY,
@Value_Name='TcpPort',
@Value=@PortNumber OUTPUT

DECLARE @result VARCHAR(100)
--set @result=(SELECT @@SERVERNAME)
SET @result='Server Name = ' + (SELECT @@SERVERNAME)+CHAR(13)+CHAR(9)+'IP = ' + @IP +CHAR(13)+CHAR(9) + 'SQL Port Number = ' + @PortNumber
PRINT @result
RETURN
Finish:
SET @result='Server Name = ' + (SELECT @@SERVERNAME)+CHAR(13)+CHAR(9)+'IP = ' + @IP +CHAR(13)+CHAR(9) + 'SQL Port Number = 1433'

PRINT @result

