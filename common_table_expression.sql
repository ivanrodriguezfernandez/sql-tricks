use [databasename]

IF EXISTS (SELECT 1 FROM SYS.OBJECTS  WHERE [TYPE]='IF' AND NAME='GetDateRanges')
BEGIN
	DROP FUNCTION GetDateRanges
END
GO
CREATE FUNCTION GetDateRanges
(
	@ItemID uniqueidentifier, 
	@EffectiveDate DATETIME,
	@DeletionDate DATETIME
)
RETURNS TABLE
AS
RETURN
(
   --common table expression
   WITH DateSequence_CTE(ItemID,NewDate) as
	(
		Select @ItemID,@EffectiveDate
			union all
		Select @ItemID, dateadd(day, 1, NewDate)
			from DateSequence_CTE 
			where NewDate < @DeletionDate
	)
	Select * from DateSequence_CTE  
)
GO

select * from dbo.GetDateRanges(NEWID(),'2018-09-16 10:57:40.073','2018-09-17 10:57:40.073') option (maxrecursion 0)

