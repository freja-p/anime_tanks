class_name Hitbox
extends Area3D

signal hit_by(entity : Entity, damage : float)

@export var ownerEntity : Entity_Vehicle
@export var health_manager : HealthManager
@export var buff_tracker : BuffTracker


func get_entity() -> Entity:
	return ownerEntity


func hit(damage : float, shooter : Entity, modifiers : Array[BuffData]):
	for mod in modifiers:
		buff_tracker.add_buff(mod)
	health_manager.hurt(damage)
	hit_by.emit(shooter, damage)
	

func disable() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	$MeshInstance3D.visible = false
	
	
func enable() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	$MeshInstance3D.visible = true
	
