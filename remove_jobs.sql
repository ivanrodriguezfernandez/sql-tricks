--BEGIN REMOVE JOBS
DECLARE @jobId binary(16) 

WHILE (1=1)
BEGIN
SET @jobId = NULL
SELECT TOP 1 @jobId = j.job_id FROM msdb.dbo.sysjobs AS j INNER JOIN sys.syslogins AS l ON j.owner_sid = l.sid WHERE l.name  like '%ivan%'

IF @@ROWCOUNT = 0
BREAK

IF (@jobId IS NOT NULL)
BEGIN
EXEC msdb.dbo.sp_delete_job @jobId
END
END
 --END REMOVE JOBS