USE DW_SSIS_CONFIG
DECLARE @INITIAL_DATE DATETIME
SET @INITIAL_DATE = (SELECT MAX(Starttime) FROM dbo.sysdtslog90 WHERE SOURCE = 'Initial_ETL' AND Event = 'packagestart')

;WITH [START]
      AS( SELECT    sysdtslog90.Source ,
                    sysdtslog90.starttime,
                    sysdtslog90.Executionid
           FROM     dbo.sysdtslog90
           WHERE    sysdtslog90.Event = 'packagestart'
        )
        SELECT [START].Source AS Package_Name,
                DATEDIFF(MINUTE, [START].Starttime, sysdtslog90.endtime) AS Duration_Mins ,
                CONVERT(VARCHAR,[START].Starttime,103) AS Date_Executed,
				DATENAME(DW,[START].Starttime) AS Week_Day,
				[START].Starttime as StartTime,
				sysdtslog90.endtime as EndTime,
				SYSDTSLOG90.Operator as USER_
        FROM    DW_SSIS_CONFIG.dbo.sysdtslog90
                INNER JOIN [START] ON 
                [START].Executionid = dbo.SYSDTSLOG90.Executionid
        WHERE   sysdtslog90.Event = 'packageend'
  		AND		[START].Starttime >= @INITIAL_DATE    
		--AND		[START].Source = 'AGREEMENT_DIM'
        --AND sysdtslog90.Source LIKE '%Initial_ETL%'
        ORDER BY [START].Starttime DESC