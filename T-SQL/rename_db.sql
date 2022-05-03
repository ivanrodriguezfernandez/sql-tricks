use master;

-- RENAME DATABASE (LOGICAL & Physical)

-- CREATE FUNTION FOR RENAME DATABASE
IF EXISTS (SELECT * FROM SYS.OBJECTS  WHERE NAME='fn_rename_db' AND [type]='FN')
BEGIN
	DROP FUNCTION fn_rename_db
END
GO
CREATE FUNCTION fn_rename_db(
@old_db_name nvarchar(255),
@new_db_name nvarchar(255),
@mdf_path nvarchar(255),
@log_path nvarchar(255)
)
RETURNS NVARCHAR(MAX)
AS BEGIN
	-- Generate
	DECLARE @SQL NVARCHAR(MAX) 
	SET @SQL = 'SELECT 1'
	
	IF EXISTS (SELECT name FROM master.sys.databases WHERE name = @old_db_name)
	BEGIN
	SET @SQL = '
			ALTER DATABASE ['+@old_db_name+'] SET SINGLE_USER WITH ROLLBACK IMMEDIATE  
			ALTER DATABASE ['+@old_db_name+']  MODIFY NAME = [' + @new_db_name+ ']
			ALTER DATABASE [' + @new_db_name+ '] MODIFY FILE (NAME = N'''+@old_db_name+''', NEWNAME = N'''+@new_db_name+''')
			ALTER DATABASE [' + @new_db_name+ '] MODIFY FILE (NAME = N''' + @new_db_name+ ''', FILENAME =  N''' + @mdf_path + @new_db_name+ '.mdf'')
			ALTER DATABASE [' + @new_db_name+ '] MODIFY FILE (NAME = N'''+@old_db_name+'_Log'', NEWNAME = N'''+ @new_db_name + '_Log'')
			ALTER DATABASE [' + @new_db_name+ '] MODIFY FILE (NAME = N'''+ @new_db_name + '_Log'', FILENAME = N''' + @log_path + @new_db_name +'_log.ldf'')
			ALTER DATABASE [' + @new_db_name+ '] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
			ALTER DATABASE [' + @new_db_name+ '] SET OFFLINE
			EXEC sp_configure ''show advanced options'',1
			RECONFIGURE WITH OVERRIDE
			EXEC sp_configure ''xp_cmdshell'', 1
			RECONFIGURE WITH OVERRIDE
			EXEC xp_cmdshell ''RENAME "' + @mdf_path + @old_db_name + '.mdf" '+ @new_db_name + '.mdf'', NO_OUTPUT
			EXEC xp_cmdshell ''RENAME "' + @log_path + @old_db_name + '_log.ldf" '+ @new_db_name + '_log.ldf'', NO_OUTPUT

			EXEC sp_configure ''xp_cmdshell'', 0
			RECONFIGURE WITH OVERRIDE
			EXEC sp_configure ''show advanced options'',0
			RECONFIGURE WITH OVERRIDE
			ALTER DATABASE ['+@new_db_name+'] SET ONLINE
			ALTER DATABASE ['+@new_db_name+'] SET MULTI_USER
			'
END
RETURN @SQL
END

GO
-- END FUNCTION :


-- CONFIGURATION
----------------------------------------------------------------------------------
DECLARE @old_database_name nvarchar(255) = 'OLD_DB_NAME'; 
DECLARE @new_database_name nvarchar(255) = 'NEW_DB_NAME';
----------------------------------------------------------------------------------

--Get Physical File Path (DATA)
DECLARE @mdf NVARCHAR(255) 
SET @mdf = (select physical_name FROM sys.master_files WHERE database_id = DB_ID(@old_database_name) and type_desc='ROWS')
DECLARE @mdf_path nvarchar(255) 
SET @mdf_path = (SELECT SUBSTRING(@mdf,0, LEN(@mdf)- CHARINDEX('\',REVERSE(@mdf))+2))

--Get Physical File Path (LOG)
DECLARE @log NVARCHAR(255) 
SET @log =  (select physical_name FROM sys.master_files WHERE database_id = DB_ID(@old_database_name) and type_desc='LOG')
DECLARE @log_path nvarchar(255) 
SET @log_path = (SELECT SUBSTRING(@log,0, LEN(@log)- CHARINDEX('\',REVERSE(@log))+2))

-- EXECUTE FUNCTION 
DECLARE @query  NVARCHAR(MAX)  = dbo.fn_rename_db(@old_database_name,@new_database_name,@mdf_path,@log_path)
execute(@query)
