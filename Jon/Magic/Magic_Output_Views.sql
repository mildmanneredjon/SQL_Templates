--Jon Eden 13/02/2009 ©
--Best viewed, results to text

SET NOCOUNT ON

USE MagicSDE
GO

DECLARE  @MAGICUSER CHAR(8)
DECLARE  @MAGICUSERNO INT

SET @MAGICUSER = UPPER(SUBSTRING(SUSER_SNAME(),CHARINDEX('\',SUSER_SNAME()) + 1,8))
--SET @MAGICUSER = 'COCKROFN'

SET @MAGICUSERNO = (SELECT SEQUENCE
                    FROM   [_SMDBA_].[_PERSONNEL_]
                    WHERE  CODE = @MAGICUSER)

--SELECT @MAGICUSER
--SELECT @MAGICUSERNO

SELECT'INCIDENT PER STAFF'
SELECT   T.SEQUENCE AS 'INCIDENT #',
         @MAGICUSER AS 'USER',
         G.CODE AS 'GROUP',
         UDS.ID AS 'STATUS',
         TD.PDATE 'PASSED TO USER', --COUNT(1),
         LEFT(CONVERT(NVARCHAR(100),T.DESCRIPTION),100) AS 'DESCRIPTION (TRUNCATED)'
		 --,REPLACE(REPLACE(CONVERT(VARCHAR(100), T.DESCRIPTION), CHAR(13), CHAR(32)), CHAR(10), CHAR(32)) AS 'COMMENTS'
FROM     [_SMDBA_].[_TELMASTE_] T,
         [_SMDBA_].[_GROUPS_] G,
         [_SMDBA_].[_TELDETAI_] TD,
         [_SMDBA_].[_UDSTATUS_] UDS
WHERE    T.[SENT TO] = @MAGICUSERNO
         AND T.[_GROUP_] = G.SEQUENCE
         AND T.STATUS = 'O'
         AND T.[SEQ_UDSTATUS:] = UDS.SEQUENCE
         AND T.SEQUENCE = TD.[PROBLEM #]
         AND TD.SEQUENCE = (SELECT MAX(SEQUENCE)
                            FROM   [_SMDBA_].[_TELDETAI_]
                            WHERE  [PROBLEM #] = TD.[PROBLEM #]
                                   AND (ACTION = 8
                                         OR ACTION = 10))
ORDER BY 4,
         1,
         5


--SELECT 'GROUPS PER STAFF'
--SELECT G.SEQUENCE
--FROM   [_SMDBA_].[_GROUPS_] G,
--       [_SMDBA_].[_GROUPDET_] GD
--WHERE  G.SEQUENCE = GD.[_GROUP_]
--       AND GD.[_MEMBER_] = @MAGICUSERNO


SELECT 'UNASSIGNED INCIDENT PER GROUP'
SELECT   T.SEQUENCE AS 'INCIDENT #',
         G.CODE AS 'GROUP',
         UDS.ID AS 'STATUS',
         TD.PDATE AS 'PASSED TO GROUP'
FROM     [_SMDBA_].[_TELMASTE_] T,
         [_SMDBA_].[_GROUPS_] G,
         [_SMDBA_].[_TELDETAI_] TD,
         [_SMDBA_].[_UDSTATUS_] UDS
WHERE    T.[SENT TO] IS NULL 
         AND T.STATUS = 'O'
         AND T.[SEQ_UDSTATUS:] = UDS.SEQUENCE
         AND T.[_GROUP_] = G.SEQUENCE
         AND T.SEQUENCE = TD.[PROBLEM #]
         AND T.[_GROUP_] IN (SELECT G.SEQUENCE
                             FROM   [_SMDBA_].[_GROUPS_] G,
                                    [_SMDBA_].[_GROUPDET_] GD
                             WHERE  G.SEQUENCE = GD.[_GROUP_]
                                    AND GD.[_MEMBER_] = @MAGICUSERNO)
         AND TD.SEQUENCE = (SELECT MAX(SEQUENCE)
                            FROM   [_SMDBA_].[_TELDETAI_]
                            WHERE  [PROBLEM #] = TD.[PROBLEM #]
                                   AND (ACTION = 7
                                         OR ACTION = 10))
ORDER BY 3,
         1,
         4

SELECT 'CR PER STAFF'
SELECT   C.SEQUENCE AS 'CR #',
         @MAGICUSER AS 'USER',
         G.CODE AS 'GROUP',
         UDS.ID AS 'STATUS',
         CD.PDATE AS 'PASSED TO USER',
		 LEFT(CONVERT(NVARCHAR(100),C.DESCRIPTION),100) AS 'DESCRIPTION (TRUNCATED)'
FROM     [_SMDBA_].[_CHANGE_] C,
         [_SMDBA_].[_GROUPS_] G,
         [_SMDBA_].[_CHANGEDET_] CD,
         [_SMDBA_].[_CMSTATUS_] UDS
WHERE    C.ASSIGNED_TO = @MAGICUSERNO
         AND C.[_GROUP_] = G.SEQUENCE
         AND C.STATE = 'O'
         AND C.SEQ_CMSTATUS = UDS.SEQUENCE
         AND C.SEQUENCE = CD.CHANGE
         AND CD.SEQUENCE = (SELECT MAX(SEQUENCE)
                            FROM   [_SMDBA_].[_CHANGEDET_]
                            WHERE  CHANGE = C.SEQUENCE
                                   AND (ACTION = 56
                                         OR ACTION = 52))
ORDER BY 4,
         1,
         5

SELECT 'UNASSIGNED CR PER GROUP'
SELECT   C.SEQUENCE AS 'CR #',
         G.CODE AS 'GROUP',
         UDS.ID AS 'STATUS',
         CD.PDATE AS 'PASSED TO GROUP'
FROM     [_SMDBA_].[_CHANGE_] C,
         [_SMDBA_].[_GROUPS_] G,
         [_SMDBA_].[_CHANGEDET_] CD,
         [_SMDBA_].[_CMSTATUS_] UDS
WHERE    C.ASSIGNED_TO IS NULL 
         AND C.STATE = 'O'
         AND C.SEQ_CMSTATUS = UDS.SEQUENCE
         AND C.[_GROUP_] = G.SEQUENCE
         AND C.SEQUENCE = CD.CHANGE
         AND C.[_GROUP_] IN (SELECT G.SEQUENCE
                             FROM   [_SMDBA_].[_GROUPS_] G,
                                    [_SMDBA_].[_GROUPDET_] GD
                             WHERE  G.SEQUENCE = GD.[_GROUP_]
                                    AND GD.[_MEMBER_] = @MAGICUSERNO)
         AND CD.SEQUENCE = (SELECT MAX(SEQUENCE)
                            FROM   [_SMDBA_].[_CHANGEDET_]
                            WHERE  CHANGE = C.SEQUENCE
                                   AND (ACTION = 57
                                         OR ACTION = 52))
ORDER BY 3,
         1,
         4

IF EXISTS (SELECT 1
           FROM   [_SMDBA_].[_GROUPS_] G,
                  [_SMDBA_].[_GROUPDET_] GD
           WHERE  G.SEQUENCE = GD.[_GROUP_]
                  AND GD.[_MEMBER_] = @MAGICUSERNO
                  AND G.CODE = 'CHANGE_ASSESSORS')
BEGIN
SELECT 'CR ASSESSMENTS';
WITH CR_DET AS --CTE
(
	SELECT   CAS.CHANGE, 
			 --CAS.RECOMMEND 
			 REPLACE(REPLACE(CONVERT(VARCHAR(1000), CAS.RECOMMEND), CHAR(13), CHAR(32)), CHAR(10), CHAR(32)) AS 'RECOMMEND'
	FROM     [_SMDBA_].[_CHANGEASMT_] CAS 
	WHERE    CHANGE IN (SELECT C.SEQUENCE
						FROM   [_SMDBA_].[_CHANGE_] C,
							   [_SMDBA_].[_CHANGEASMT_] CAS
						WHERE  CAS.ASSESSOR = @MAGICUSERNO
							   AND C.STATE = 'O'
							   AND C.SEQUENCE = CAS.CHANGE
							   AND CAS.COST_ESTIMATE IS NULL)
			 AND CAS.ASSESSOR <> @MAGICUSERNO
)
  SELECT   C.SEQUENCE AS 'CR #',
           @MAGICUSER AS 'USER',
           G.CODE AS 'GROUP',
           LEFT(D.RECOMMEND, 125) AS 'COMMENTS (TRUNCATED)'
  FROM     [_SMDBA_].[_CHANGE_] C,
           [_SMDBA_].[_CHANGEASMT_] CAS,
           [_SMDBA_].[_GROUPS_] G,
		   [CR_DET] D
  WHERE    CAS.CHANGE = D.CHANGE
		   AND CAS.ASSESSOR = @MAGICUSERNO
           AND C.STATE = 'O'
           AND CAS.[_GROUP_] = G.SEQUENCE
           AND C.SEQUENCE = CAS.CHANGE
           AND CAS.COST_ESTIMATE IS NULL
  ORDER BY 1
END

IF EXISTS (SELECT 1
           FROM   [_SMDBA_].[_GROUPS_] G,
                  [_SMDBA_].[_GROUPDET_] GD
           WHERE  G.SEQUENCE = GD.[_GROUP_]
                  AND GD.[_MEMBER_] = @MAGICUSERNO
                  AND G.CODE = 'CHANGE_APPROVERS')
BEGIN
SELECT 'CR APPROVALS'
  SELECT   C.SEQUENCE AS 'CR #',
           @MAGICUSER AS 'USER',
           G.CODE AS 'GROUP'
  FROM     [_SMDBA_].[_CHANGE_] C,
           [_SMDBA_].[_CHANGEAPPR_] CAP,
           [_SMDBA_].[_GROUPS_] G
  WHERE    CAP.APPROVER = @MAGICUSERNO
           AND C.STATE = 'O'
           AND CAP.[_GROUP_] = G.SEQUENCE
           AND C.SEQUENCE = CAP.CHANGE
           AND CAP.DECISION IS NULL 
  ORDER BY 1
END

--select convert(varchar(10), getdate(), 103)

SELECT COUNT(1) AS 'NO. INCIDENT(S) CLOSED TODAY'
FROM   [_SMDBA_].[_TELMASTE_]
WHERE  [CLOSED BY] = @MAGICUSERNO
       AND CONVERT(VARCHAR(10),[CLOSED ON],103) = CONVERT(VARCHAR(10),getdate(),103)

SELECT COUNT(1) AS 'NO. CR(S) CLOSED TODAY'
FROM   [_SMDBA_].[_CHANGE_] C,
       [_SMDBA_].[_PERSONNEL_] P
WHERE  C.LASTUSER = P.CODE
       AND P.SEQUENCE = @MAGICUSERNO
       AND CONVERT(VARCHAR(10),C.DATE_CLOSED,103) = CONVERT(VARCHAR(10),GETDATE(),103)

--select top 10 * from [_SMDBA_].[_PERSONNEL_] order by 1 desc

--select top 10 * from [_SMDBA_].[_CHANGE_] C order by 1 desc

--select top 30 * from [_SMDBA_].[_CHANGEDET_] order by 1 desc

--select datediff(s, '2008-05-09 15:48:34.000', getdate())/60