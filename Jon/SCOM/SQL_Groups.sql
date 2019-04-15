SELECT * 
FROM vManagedEntity
Where ManagedEntityTypeRowID in 
(
	SELECT ManagedEntityTypeRowID 
	FROM dbo.ManagedEntityDerivedTypeHierarchy
	((
		SELECT ManagedEntityTypeRowId 
		FROM vmanagedentitytype
		WHERE managedentitytypesystemname = 'system.group'),0
	)
)
AND DisplayName LIKE 'SQL%'
ORDER BY DisplayName
