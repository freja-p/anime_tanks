class_name TurretController
extends Node

enum TurretModes {
	ACTIVE,
	LOCK,
	RESET,
	DYING,
}

enum TargettingState {
	TURNING,
	REACHED,
}

enum AimState {
	NOTHING,
	ENTITY,
}

@export var barrel : Node3D
@export var turret : Node3D
@export var virTurret : Node3D
@export var virBarrel : Node3D
@export var primaryHardpoint : Node3D
@export var secondaryHardpoint : Node3D
@export var specialHardpoint : Node3D
@export var barrelRay : RayCast3D

@export_category("Stats")
@export var rotateSpeedDeg : float = 45
@export var elevateSpeedDeg : float = 45
@export var elevationMin : float = -3
@export var elevationMax : float = 80

@onready var parent : Node3D = get_parent()

# Turret Control
var turretTargetRad : float
var barrelTargetRad : float

var radToTurretTarget : float
var radToBarrelTarget : float

var current_mode : TurretModes = TurretModes.ACTIVE
var targetting_state : TargettingState = TargettingState.REACHED
var aiming_state : AimState = AimState.NOTHING
# Aiming Raycast
var lookingAtEntity : Entity = null
var entityWasAlive : bool = true


func _ready():
	virTurret.global_position = turret.global_position
	virTurret.global_transform.basis = turret.global_transform.basis
	
	virBarrel.global_position = barrel.global_position
	virBarrel.global_transform.basis = barrel.global_transform.basis
	
	elevationMin = deg_to_rad(elevationMin)
	elevationMax = deg_to_rad(elevationMax)

func _process(delta):
	match current_mode:
		TurretModes.ACTIVE:
			_update_turret_rotation(delta)
			pass
		TurretModes.LOCK:
			pass
		TurretModes.RESET:
			turretTargetRad = 0
			barrelTargetRad = 0
			_update_turret_rotation(delta)
			pass
		TurretModes.DYING:
			pass
	
func _physics_process(_delta):
	var collider = barrelRay.get_collider()
	if collider is Hitbox:
		lookingAtEntity = collider.get_entity() as Entity
		if lookingAtEntity.dying:
			lookingAtEntity = null
			_change_aim_state(AimState.NOTHING)
		else:
			_change_aim_state(AimState.ENTITY)
	else:
		lookingAtEntity = null
		_change_aim_state(AimState.NOTHING)

func _update_turret_rotation(delta : float):
	radToTurretTarget = turret.rotation.y - turretTargetRad
	radToBarrelTarget = barrel.rotation.x - barrelTargetRad 
	
	if is_zero_approx(radToBarrelTarget) and is_zero_approx(radToTurretTarget):
		_change_targetting_state(TargettingState.REACHED)
		return
	else:
		_change_targetting_state(TargettingState.TURNING)
#	print("%s: (%f | %f)" % [get_node("../../").name, radToTurretTarget, radToBarrelTarget])
	if not is_zero_approx(radToTurretTarget):
		var to_rotate = deg_to_rad(rotateSpeedDeg) * delta
		if abs(radToTurretTarget) < to_rotate:
#			print("\treduced rotate")
			to_rotate = abs(radToTurretTarget)

		if (radToTurretTarget < 0 && radToTurretTarget > -PI) || radToTurretTarget > PI:
			turret.rotate_y(to_rotate)
		else:
			turret.rotate_y(-to_rotate)
			
	if not is_zero_approx(radToBarrelTarget):
		var to_elevate = deg_to_rad(elevateSpeedDeg) * delta
#		print("Frame elevation degrees: %f" % to_elevate)
		if abs(radToBarrelTarget) < to_elevate:
#			print("\treduced elevate")
			to_elevate = abs(radToBarrelTarget)
		if radToBarrelTarget < 0:
			barrel.rotate_x(to_elevate)
		else:
			barrel.rotate_x(-to_elevate)	


func aim_at(target : Vector3) -> void:
	if current_mode == TurretModes.LOCK or current_mode == TurretModes.RESET:
		return
		
	var dir : Vector3 = turret.position.direction_to(parent.to_local(target))
	
	dir = dir.slide(parent.basis.y).normalized()
	
	
	turretTargetRad = -dir.signed_angle_to(parent.basis.z, parent.basis.y)
	virTurret.rotation.y = turretTargetRad
	
#	print(rad_to_deg(turretTargetRad))
	
	var virBarrelRelPoint : Vector3 = virTurret.to_local(target) - virBarrel.position
	var virBarrelAngle : float = -atan(virBarrelRelPoint.y / virBarrelRelPoint.z)
	barrelTargetRad = clampf(virBarrelAngle, elevationMin, elevationMax) 


func turn_to_rad(yaw : float, pitch : float):
	turretTargetRad = yaw
	barrelTargetRad = pitch
	
	
func change_modes(new_mode : TurretModes):
	match new_mode:
		TurretModes.ACTIVE:
			pass
		TurretModes.LOCK:
			pass
		TurretModes.RESET:
			turretTargetRad = 0
			barrelTargetRad = 0
			pass
		TurretModes.DYING:
			pass
	current_mode = new_mode


func _change_aim_state(new_state : AimState):
	if new_state == aiming_state:
		return
		
	aiming_state = new_state


func _change_targetting_state(new_state : TargettingState):
	if new_state == targetting_state:
		return
		
	targetting_state = new_state

func get_barrel_ray() -> RayCast3D:
	return barrelRay
	
	
func get_barrel_aim() -> Vector3:
	if barrelRay.is_colliding():
		return barrelRay.get_collision_point()
	else:
		var vector = -barrelRay.basis.z * barrelRay.target_position.length()
		return barrelRay.to_global(vector)
