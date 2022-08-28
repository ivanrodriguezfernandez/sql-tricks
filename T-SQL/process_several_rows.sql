SELECT * FROM Roles tp
INNER JOIN (SELECT
	ROW_NUMBER() OVER (ORDER BY Id) 'RowNumber',
	Id
FROM Roles) rn
ON tp.Id=rn.Id
WHERE rn.RowNumber BETWEEN 1 AND 10
