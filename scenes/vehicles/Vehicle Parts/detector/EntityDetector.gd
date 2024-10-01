class_name EntityDetector
extends Node3D

@export var turret : TurretComponent
@export var detectorRaysScene : PackedScene
@export var detectionLifetime : float

var parentEntity : Entity
@onready var looking = %Looking

var barrelPoint : Node3D
var detectedEntities : Dictionary
var visibleEntities : Dictionary
var detectedAllies : Dictionary
signal entityDied(entity : Entity, killer : Entity)
signal visibleEntitiesAdded(entity : Entity)
signal visibleEntitiesRemoved(entity : Entity)

func _ready():
	barrelPoint = turret.get_projectile_spawn_node() 

func _physics_process(delta):
	for key in detectedEntities:
		var detectInfo : EntityDetectInfo = detectedEntities[key]
		var entity : Entity = detectInfo.trackedEntity
		
		detectInfo.update_global_basis(entity.global_position)
	pass

func _process(delta):
	_reposition_barrelDetector()

func hit_by(entity : Entity, damage : float) -> void:
	alert_allies(entity)

func alert_allies(entity : Entity):
	for ally in detectedAllies.values():
		ally.alert(entity)

func _reposition_barrelDetector():
	var newPos : Vector3 = barrelPoint.global_transform.origin
	var newBas : Basis = barrelPoint.global_transform.basis
	
	looking.global_transform.origin = newPos - newBas.z * 50
	looking.global_transform.basis = newBas

func _on_detection_areas_area_entered(area):
	if area is Hitbox:
		var areaEntity : Entity = area.get_entity()
		
		if areaEntity == parentEntity or areaEntity.name in detectedAllies or areaEntity.name in detectedEntities or areaEntity.dying:
			return
		
		if areaEntity.is_connected("died", _on_entity_died):
			print("Entity %s already connected" % [areaEntity])
		else:
			areaEntity.died.connect(_on_entity_died)
			
		if areaEntity.faction.is_allied_to(parentEntity.faction) and not areaEntity.name in detectedAllies:
			detectedAllies[areaEntity.name] = areaEntity
			
		elif not areaEntity.name in detectedEntities:
			var detectInfo : EntityDetectInfo = detectorRaysScene.instantiate() as EntityDetectInfo
			detectInfo.name = "DetectorCast_" + areaEntity.name
			add_child(detectInfo)
			
			detectInfo.trackedEntity = areaEntity
			detectInfo.lifeTimeout = detectionLifetime
			detectInfo.detection_life_timeout.connect(_on_detect_detect_ray_life_timeout)
			detectInfo.occlusion_changed.connect(_on_occlusion_state_changed)
			
			detectedEntities[areaEntity.name] = detectInfo
			
func _on_detection_areas_area_exited(area):
	if area is Hitbox:
		var areaEntity : Entity = area.get_entity()
		if areaEntity.name in detectedAllies:
			_remove_detected_ally(areaEntity.name)

func _on_detect_detect_ray_life_timeout(entityName : String):
	# Bug: If timeout occurs while occluded inside detection range, entity will not be redetected when becoming not occluded
	_remove_detected_entity(entityName)

func _remove_detected_entity(entityName : String):
	var entity : Entity = detectedEntities[entityName].trackedEntity as Entity
	if entity.is_connected("died",_on_entity_died):
		entity.disconnect("died", _on_entity_died)
	else:
		print("Entity %s was not connected" % [entityName])
	
	detectedEntities[entityName].queue_free()
	visibleEntities.erase(entityName)
	detectedEntities.erase(entityName)
	

func _on_occlusion_state_changed(entityName : String, isOccluded : bool):
	if isOccluded:
		visibleEntities.erase(entityName)
		visibleEntitiesRemoved.emit(detectedEntities[entityName].trackedEntity)
	else:
		visibleEntities[entityName] = detectedEntities[entityName].trackedEntity
		alert_allies(detectedEntities[entityName].trackedEntity)
		visibleEntitiesAdded.emit(detectedEntities[entityName].trackedEntity)

func _remove_detected_ally(entityName : String):
		var allyEntity : Entity = detectedAllies[entityName] as Entity
#		if allyEntity.is_connected("died",_on_entity_died):
#			allyEntity.disconnect("died", _on_entity_died)
#		else:
#			print("Ally %s was not connected" % [entityName])
			
		detectedAllies.erase(entityName)

func _on_entity_died(entity : Entity, killer : Entity):
	if entity.name in detectedAllies:
#		print("%s was notified ally %s died" % [parentEntity.name, entity.name])
		_remove_detected_ally(entity.name)
		entityDied.emit(entity, killer)
	elif entity.name in detectedEntities:
#		print("%s was notified enemy %s died" % [parentEntity.name, entity.name])
		_remove_detected_entity(entity.name)
		entityDied.emit(entity, killer)
