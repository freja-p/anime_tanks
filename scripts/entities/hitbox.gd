class_name Hitbox
extends Area3D

signal hit_by(entity : Entity, damage : float)

@export var ownerEntity : Entity_Vehicle
@export var health_manager : HealthManager
@export var modifier_handler : ModifierHandler


func get_entity() -> Entity:
	return ownerEntity


func hit(damage : float, shooter : Entity, modifiers : Array[ModifierData]):
	for mod in modifiers:
		modifier_handler.add_modifier(mod)
	health_manager.hurt(damage)
	hit_by.emit(shooter, damage)
	

func disable() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	$MeshInstance3D.visible = false
	
	
func enable() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	$MeshInstance3D.visible = true
	
