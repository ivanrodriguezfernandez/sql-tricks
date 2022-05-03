EXEC sp_resetstatus [databasename];
ALTER DATABASE [databasename] SET EMERGENCY
DBCC checkdb([databasename])
ALTER DATABASE [[databasename] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DBCC CheckDB ([databasename], REPAIR_ALLOW_DATA_LOSS)
ALTER DATABASE [databasename] SET MULTI_USER