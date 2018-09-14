USE master
DECLARE @spid int
DECLARE @db_id int
IF EXISTS (SELECT name FROM sys.databases where name='<@dbname,varchar(255),>' AND state_desc='ONLINE')
BEGIN			
	--Kill of all processes connected to the database
	SELECT @db_id=dbid from sys.sysdatabases where name='<@dbname,varchar(255),>'
	SELECT TOP 1 @spid=spid from sys.sysprocesses where dbid=@db_id
	WHILE @@ROWCOUNT<>0
	BEGIN
		EXEC('Kill ' + @spid + '')
		SELECT TOP 1 @spid=spid from sys.sysprocesses where dbid=@db_id
	END
END 


-- execute control + shif + M