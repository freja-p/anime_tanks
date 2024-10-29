class_name TurretComponent
extends Node3D

signal aiming_at_entity_state_changed(isAiming : bool, entity : Entity)
signal turret_target_reached

@onready var controller : TurretController = $TurretController as TurretController


func aim_at(target : Vector3) -> void:
	activate_turret()
	controller.aim_at(target)


func turn_to_rad(yaw : float, pitch : float):
	activate_turret()
	controller.turn_to_rad(yaw, pitch)
	
	
func reset_turret():
	controller.current_state = TurretController.TURRET_STATE.RESET


func lock_turret():
	controller.current_state = TurretController.TURRET_STATE.LOCK
	
	
func activate_turret():
	controller.current_state = TurretController.TURRET_STATE.ACTIVE


func die():
	controller.current_state = TurretController.TURRET_STATE.DYING


func get_projectile_spawn_node() -> Node3D:
	return controller.projectileSpawn
	
	
func get_barrel_aim() -> Vector3:
	return controller.get_barrel_aim()


func get_barrel_ray() -> RayCast3D:
	return controller.get_barrel_ray()


func get_hardpoint_node(hardpoint : Enums.Hardpoint) -> Node3D:
	match hardpoint:
		Enums.Hardpoint.PRIMARY:
			return controller.primaryHardpoint
		Enums.Hardpoint.SECONDARY:
			return controller.secondaryHardpoint
		Enums.Hardpoint.SPECIAL:
			return controller.specialHardpoint
		Enums.Hardpoint.INTERNAL:
			return null
		_:
			print("Hardpoint not recognized in turret")
			return null
