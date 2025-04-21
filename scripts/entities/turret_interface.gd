class_name TurretInterface
extends Node3D

func turret_look_at(target: Vector3) -> void:
	push_error("METHOD NOT IMPLEMENTED: TurretInterface.turret_look_at(target: Vector3, up: Vector3 = Vector3(0, 1, 0), use_model_front: bool = false)")

func elevate_barrel(worldPos : Vector3) -> void:
	push_error("METHOD NOT IMPLEMENTED: TurretInterface.elevate_barrel(worldPos : Vector3)")

func get_barrel_origin() -> Vector3:
	push_error("METHOD NOT IMPLEMENTED: TurretInterface.get_barrel_origin()")
	return Vector3.ZERO

func get_barrel_rotation() -> Vector3:
	push_error("METHOD NOT IMPLEMENTED: TurretInterface.get_barrel_rotation()")
	return Vector3.ZERO
	
func get_projectileSpawn_origin() -> Vector3:
	push_error("METHOD NOT IMPLEMENTED: TurretInterface.get_projectileSpawn_origin()")
	return Vector3.ZERO
	
func get_projectileSpawn_rotation() -> Vector3:
	push_error("METHOD NOT IMPLEMENTED: TurretInterface.get_projectileSpawn_rotation()")
	return Vector3.ZERO
