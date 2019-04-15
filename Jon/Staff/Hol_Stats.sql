/*RSSHALOGEN\INERT*/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

USE [HRProEmployee]
GO

SELECT 
	Full_Name
	--,id
	,Holiday_Entitlement AS Entitlement
	,Holiday_Trade_Up AS TradeUp
	,Holiday_Entitlement + Holiday_Trade_Up AS Total_Entitlement
	,Holiday_Taken AS Taken_Or_Booked
	,Holiday_Balance AS Remaining
	,CONVERT(TINYINT,(Holiday_Taken / (Holiday_Entitlement + Holiday_Trade_Up)) * 100) AS Taken_Perc
FROM [dbo].[Personnel_Records] 
--WHERE Full_Name IN ('Jon Eden','Atif Hakim','Jamie Dolan','Dipesh Mistry','Mark Ma','Paul Higgins', 'Richard Dodgson')
WHERE (Line_Manager = 'Jon Eden' OR Full_Name = 'Jon Eden')
AND Holiday_Entitlement <> 0.00
AND Leaving_Date IS NULL 
ORDER BY CONVERT(TINYINT,(Holiday_Taken / Holiday_Entitlement) * 100)


