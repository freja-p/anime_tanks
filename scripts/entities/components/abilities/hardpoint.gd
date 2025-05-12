class_name Hardpoint
extends Node3D

func update_target(new_target : Vector3) -> void:
	global_basis = Basis.looking_at(global_position.direction_to(new_target), Vector3.UP, true)
	
