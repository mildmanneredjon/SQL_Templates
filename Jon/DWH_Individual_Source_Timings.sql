USE DW_SSIS_CONFIG
GO

--DM_STAT_CUSTOMER_DIM - Move data from the temp table to StatementMart
--DM_STAT_AGREEMENT_DIM - Move data from the temp table to StatementMart
--DM_STOCK - Move data from temp table into StatementMart
--dm_stat_agreement
--dm_stat_customer
--dm_stat_transaction
--dm_stat_latest_transaction

DECLARE @INITIAL_DATE DATETIME
DECLARE @SOURCE VARCHAR(100)
SET @INITIAL_DATE = (SELECT MAX(Starttime) FROM dbo.sysdtslog90 WHERE SOURCE = 'Initial_ETL' AND Event = 'packagestart')
SET @SOURCE = 'DM_STAT_CUSTOMER_DIM - Move data from the temp table to StatementMart'

SELECT  TOP 100
[SOURCE], 
MIN(STARTTIME) AS [STARTTIME],
MAX(ENDTIME) AS [ENDTIME],
DATEDIFF(MINUTE, MIN(STARTTIME), MAX(ENDTIME)) AS Duration_Mins,
CONVERT(VARCHAR(10),MIN(STARTTIME),103) AS [DATE]
FROM DW_SSIS_CONFIG.dbo.sysdtslog90
WHERE ([SOURCE] = @SOURCE AND [Message] LIKE 'Execute phase is beginning%')
OR ([SOURCE] = @SOURCE AND [Message] LIKE 'Post Execute phase is beginning%')
GROUP BY [SOURCE], EXECUTIONID
ORDER BY MIN(STARTTIME) DESC