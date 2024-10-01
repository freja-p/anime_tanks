class_name Hitbox
extends Area3D

@export var ownerEntity : Entity_Vehicle

func get_entity() -> Entity:
	return ownerEntity

func hit(damage : float, shooter : Entity, modifiers : Array[ModifierData]):
	ownerEntity.hurt(damage)
	for mod in modifiers:
		ownerEntity.modifier_handler.add_modifier(mod)

func disable() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	$MeshInstance3D.visible = false
	
func enable() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	$MeshInstance3D.visible = true
