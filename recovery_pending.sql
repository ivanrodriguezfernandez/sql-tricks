
ALTER DATABASE [databasename] SET EMERGENCY;
GO
ALTER DATABASE [databasename] set single_user
GO
DBCC CHECKDB [databasename] REPAIR_ALLOW_DATA_LOSS) WITH ALL_ERRORMSGS;
GO 
ALTER DATABASE [databasename] set multi_user
GO
