/* Select all Computers */
SELECT
MET.*,
ME.*
from dbo.vManagedEntityType MET, 
dbo.vManagedEntity ME 
WHERE ME.FullName LIKE '%Windows.Computer:%' 
AND MET.ManagedEntityTypeDefaultName = 'Computer'
ORDER BY ME.Name

select distinct vme2.displayname , vme.DisplayName
FROM vrelationship r
INNER JOIN vManagedEntity vme 
	ON vme.ManagedEntityRowId=r.TargetManagedEntityRowId
INNER JOIN vManagedEntity vme2 
	ON vme.TopLevelHostManagedEntityRowId=vme2.ManagedEntityRowId
INNER JOIN vRelationshipManagementGroup rmg 
	ON rmg.RelationshipRowId=r.RelationshipRowId
where SourceManagedEntityRowId IN 
	(
		SELECT ManagedEntityRowId 
		FROM vManagedEntity
		INNER JOIN vRelationship 
			ON vManagedEntity.ManagedEntityRowId=vRelationship.SourceManagedEntityRowId
		INNER JOIN vRelationshipType 
			ON vRelationship.RelationshipTypeRowId=vRelationshipType.RelationshipTypeRowId
		INNER JOIN vRelationshipManagementGroup 
			ON vRelationshipManagementGroup.RelationshipRowId=vRelationship.RelationshipRowId
		WHERE (vRelationshipType.RelationshipTypeSystemName='Microsoft.SystemCenter.ComputerGroupContainsComputer' OR vRelationshipType.RelationshipTypeSystemName LIKE '%InstanceGroup%')
		AND vRelationshipManagementGroup.ToDateTime IS NULL
	)
AND rmg.ToDateTime IS NULL
ORDER BY vme2.displayname