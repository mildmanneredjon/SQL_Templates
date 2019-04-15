USE DBS_Scheduler;

DECLARE @TARGET VARCHAR(20) = 'PFGSQLT3N02'

SELECT
	T.Connection_Address
	,T.MonitoredItem_GUID
	,TG.Target_Group_Name
	,T.Enabled
	,T.ContactAttempts
	,T.Contact_Lost
	,Last_Contact
	,Last_Contact_Attempt_Result
FROM [DBS_Scheduler].[Action].[Target] T
JOIN [Action].[Target_Target_Group] TTG
	ON T.Target_id = TTG.Target_id
JOIN [Action].[Target_Group] TG
	ON TG.Target_Group_id = TTG.Target_Group_id
WHERE T.Connection_Address = @TARGET
ORDER BY T.Connection_Address 

