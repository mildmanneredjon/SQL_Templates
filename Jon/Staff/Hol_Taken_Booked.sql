SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

USE [HRProEmployee]
GO

DECLARE @YEAR SMALLINT = 2018

SELECT 
	PR.Full_Name
	,PR.ID
	,A.DURATION
	,A.START_DATE
	,A.END_DATE
	,A.START_SESSION
	,A.END_SESSION
FROM [dbo].[Personnel_Records]  PR
JOIN [dbo].[tbuser_Absence] A
	ON PR.ID = A.ID_1
WHERE (PR.Line_Manager = 'Jon Eden' OR PR.Full_Name = 'Jon Eden')
and A.TYPE = 'hols'
  and A._DELETED is null
AND Leaving_Date IS NULL 
AND DATEPART(YEAR,A.START_DATE) = @YEAR
--AND PR.Full_Name = 'Paul Higgins'
ORDER BY PR.Full_Name, A.start_date desc