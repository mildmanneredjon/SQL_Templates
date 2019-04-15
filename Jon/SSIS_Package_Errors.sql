USE DW_SSIS_CONFIG
DECLARE @INITIAL_DATE DATETIME
SET @INITIAL_DATE = (SELECT MAX(Starttime) FROM dbo.sysdtslog90 WHERE SOURCE = 'Initial_ETL' AND Event = 'packagestart')

SELECT  SYSDTSLOG90.Event ,
        SYSDTSLOG90.Source ,
        SYSDTSLOG90.Message ,
        CONVERT(VARCHAR, SYSDTSLOG90.Starttime) [Time]
FROM    DW_SSIS_CONFIG.dbo.SYSDTSLOG90
WHERE   SYSDTSLOG90.EVENT NOT IN ( 'OnProgress', 
                                   'OnInformation', 
                                   'PackageEnd', 
                                   'PackageStart',
                                   'User:OnProgress',
                                   'User:OnInformation',
                                   'OnPostExecute',
                                   'OnPreExecute',
                                   'OnWarning',
                                   'User:OnWarning',
                                   'User:OnPostExecute',
                                   'User:OnPreExecute',
                                   'User:OnPipelineRowsSent',
                                   'OnPipelineRowsSent',
                                   'User:OnPostValidate',
                                   'OnPostValidate',
                                   'User:PackageEnd',
                                   'User:PackageStart'
                                 )
        AND SYSDTSLOG90.Starttime > @INITIAL_DATE  
        --AND SYSDTSLOG90.Operator = 'rs\maestro'
        --AND SYSDTSLOG90.Source LIKE '%XXX'
GROUP BY SYSDTSLOG90.Event ,
        SYSDTSLOG90.Source ,
        SYSDTSLOG90.Message ,
        SYSDTSLOG90.Endtime ,
        SYSDTSLOG90.Starttime
ORDER BY SYSDTSLOG90.Endtime DESC

