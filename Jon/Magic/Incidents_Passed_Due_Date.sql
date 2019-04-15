--HOSWIZARD\PRESTO
SELECT 
	T.SEQUENCE AS [INCIDENT #]
	,T.[SENT TO] AS [USER_CODE]
	,P.CODE AS [USER_NAME]
	,G.CODE AS [GROUP]
	,UDS.ID AS [STATUS]
	,T.[DATE OPEN] AS [DATE_OPEN]
	,TD.PDATE [PASSED TO USER]
	,T.[DUE_DATE:] AS [DATE_DUE]
	,T.[CLOSED ON] AS [DATE_CLOSED]
	,LEFT(CONVERT(NVARCHAR(1000),T.DESCRIPTION),1000) AS [DESCRIPTION (TRUNCATED)]

FROM     [MagicSDE].[_SMDBA_].[_TELMASTE_] T WITH (READUNCOMMITTED)

JOIN [MagicSDE].[_SMDBA_].[_GROUPS_] G WITH (READUNCOMMITTED)
	ON T.[_GROUP_] = G.SEQUENCE
	
JOIN [MagicSDE].[_SMDBA_].[_TELDETAI_] TD WITH (READUNCOMMITTED)
	ON T.SEQUENCE = TD.[PROBLEM #]
	
JOIN [MagicSDE].[_SMDBA_].[_UDSTATUS_] UDS WITH (READUNCOMMITTED)
	ON T.[SEQ_UDSTATUS:] = UDS.SEQUENCE
	
JOIN [MagicSDE].[_SMDBA_].[_PERSONNEL_] P WITH (READUNCOMMITTED)
	ON T.[SENT TO] = P.SEQUENCE
	
JOIN [MagicSDE].[_SMDBA_].[_CUSTOMER_] CU WITH (READUNCOMMITTED)
	ON ISNULL(T.[CLIENT],2932) = CU.SEQUENCE	
JOIN [MagicSDE].[_SMDBA_].[_SUBJECTS_] S WITH (READUNCOMMITTED)
	ON T.SUBJECT = S.SEQUENCE
WHERE TD.SEQUENCE = (SELECT MAX(SEQUENCE)
                            FROM   [MagicSDE].[_SMDBA_].[_TELDETAI_] WITH (READUNCOMMITTED)
                            WHERE  [PROBLEM #] = TD.[PROBLEM #]
                                   AND (ACTION = 8
                                         OR ACTION = 10))
--AND P.CODE IN('HAKIMA','MISTRYD','STEWARTD','DOLANJ')
AND G.[SEQUENCE] = 1014 --DBA_GROUP
AND T.[CLOSED ON] IS NULL
AND T.[DUE_DATE:] < GETDATE()
AND S.DESCRIPTION <> 'Service Request'
AND T.SEQUENCE > 322077
ORDER BY T.SEQUENCE DESC

