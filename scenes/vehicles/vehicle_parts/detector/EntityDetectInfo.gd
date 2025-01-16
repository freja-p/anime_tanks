class_name EntityDetectInfo
extends Node3D

var trackedEntity : Entity
var isOccluded : bool = true
var lifeTimeout : float
var checkOcclusion : bool = true
@onready var life_timer = %LifeTimer as Timer

signal detection_life_timeout(entityName : String)
signal occlusion_changed(entityName : String, status : bool)

func _physics_process(delta):
#	pass
	if checkOcclusion:
		checkOcclusion = false
		var newOcclusionState = is_entity_occluded()
		if newOcclusionState == isOccluded:
			return
		isOccluded = newOcclusionState
		occlusion_changed.emit(trackedEntity.name, isOccluded)
		if isOccluded:
			if life_timer.is_stopped():
				life_timer.start(lifeTimeout)
		else:
			life_timer.stop()
			

func update_global_basis(worldPos : Vector3) -> void:
	var global_bas : Basis = global_transform.basis
	global_transform.basis = Basis.looking_at(global_position.direction_to(worldPos))

func is_entity_occluded() -> bool:
	var ray : RayCast3D
	for child in get_children():
		if not child is RayCast3D:
			continue
		var collider : Object = child.get_collider()
		if collider is Hitbox:
			if collider.get_entity() == trackedEntity:
				return false
			
	return true

func _on_life_timeout_timeout():
	detection_life_timeout.emit(trackedEntity.name)

func _on_check_ping_timeout():
	checkOcclusion = true
