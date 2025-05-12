class_name EntityDetector
extends Node

signal entityDied(entity : Entity, killer : Entity)
signal visibleEntitiesAdded(entity : Entity)
signal visibleEntitiesRemoved(entity : Entity)

@export var turret : TurretComponent

var detectedEntities : Dictionary
var detectedAllies : Dictionary

@onready var parentEntity : Entity_Vehicle = get_parent()

func hit_by(entity : Entity, _damage : float) -> void:
	alert_allies(entity)

func alert_allies(entity : Entity):
	for ally in detectedAllies.values():
		ally.alert(entity)

func _on_detection_area_body_entered(body):
	if body is Entity_Vehicle:
		var areaEntity : Entity_Vehicle = body
		
		if areaEntity == parentEntity or areaEntity.name in detectedAllies or areaEntity.name in detectedEntities or areaEntity.dying:
			return
		
		if areaEntity.is_connected("died", _on_entity_died):
			print("Entity %s already connected" % [areaEntity])
		else:
			areaEntity.died.connect(_on_entity_died)
			
		if areaEntity.faction.is_allied_to(parentEntity.faction) and not areaEntity.name in detectedAllies:
			detectedAllies[areaEntity.name] = areaEntity
			
		elif not areaEntity.name in detectedEntities:			
			detectedEntities[areaEntity.name] = areaEntity
			
func _on_detection_area_body_exited(body):
	if body is Entity_Vehicle:
		if body.name in detectedAllies:
			_remove_detected_ally(body.name)
		elif body.name in detectedEntities:
			_remove_detected_entity(body.name)
			

func _remove_detected_entity(entityName : String):
	var entity : Entity = detectedEntities[entityName] as Entity
	if entity.is_connected("died",_on_entity_died):
		entity.disconnect("died", _on_entity_died)
	else:
		print("Entity %s was not connected" % [entityName])
	
	detectedEntities.erase(entityName)
	

func _remove_detected_ally(entityName : String):
		#var allyEntity : Entity = detectedAllies[entityName] as Entity
		#if allyEntity.is_connected("died",_on_entity_died):
			#allyEntity.disconnect("died", _on_entity_died)
		#else:
			#print("Ally %s was not connected" % [entityName])
			
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
