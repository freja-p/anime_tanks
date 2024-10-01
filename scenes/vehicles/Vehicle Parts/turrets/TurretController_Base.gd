class_name TurretController_base
extends Node3D

@export_category("Eventbus")
@export var entityEventBus : EntityEventBus

@export_category("Turrettry")
@export var elevationMin : float = -10.0
@export var elevationMax : float = 20.0
	
@export var rotateSpeedDeg : float = 40.0
@export var elevateSpeedDeg : float = 10.0

const angleErrorDeg : float = 0.2

# Child Nodes
@onready var gunBarrel : Node3D = $Base_Turret/Gun_Barrel
@onready var turret : Node3D = $Base_Turret
@onready var virTurret : Node3D = $VirtualTurret
@onready var virBarrel : Node3D = $VirtualTurret/VirtualBarrel
@onready var projectileSpawn : Node3D = $Base_Turret/Gun_Barrel/ProjectileSpawnPoint
@onready var barrelRay : RayCast3D = $Base_Turret/Gun_Barrel/BarrelTarget

# Gun Targeting
var gunBarrelPitch : float
var gunBarrelDistance : float

var turretTargetRad : float
var barrelTargetRad : float

var radToTurretTarget : float
var radToBarrelTarget : float

var rotatePos : bool

var lockTurret : bool = false
var resetTurret : bool = false
signal turret_target_reached

@export_category("Animation")
@export var ragdollScene : PackedScene
var dying : bool = false
var ragdoll : RigidBody3D

# Raycast
var isLookingAtSomething : bool = false
var isAimingAtEntity : bool = false
var lookingAtEntity : Entity = null
signal aiming_at_entity_state_changed(isAiming : bool, entity : Entity)

func _ready():
	gunBarrelPitch = abs(atan(gunBarrel.position.y / gunBarrel.position.z))
	gunBarrelDistance = gunBarrel.position.length()
	
	virTurret.position = turret.position
	virBarrel.position = gunBarrel.position
	
	elevationMin = deg_to_rad(elevationMin)
	elevationMax = deg_to_rad(elevationMax)

func _process(delta):
	if dying:
		$Base_Turret.global_position = ragdoll.global_position
		$Base_Turret.global_rotation = ragdoll.global_rotation
		return
	elif lockTurret:
		return
	
	if resetTurret:
		turretTargetRad = 0
		barrelTargetRad = 0
		
	radToTurretTarget = turret.rotation.y - turretTargetRad
	radToBarrelTarget = gunBarrel.rotation.x - barrelTargetRad 
	if is_zero_approx(radToBarrelTarget) and is_zero_approx(radToTurretTarget):
		entityEventBus.turret_target_reach.emit()
		return
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
			gunBarrel.rotate_x(to_elevate)
		else:
			gunBarrel.rotate_x(-to_elevate)	
	pass
	
func _physics_process(delta):
	isLookingAtSomething = barrelRay.is_colliding()
	var collider = barrelRay.get_collider()
	if collider is Hitbox:
		lookingAtEntity = collider.get_entity() as Entity
#		entityEventBus.looking_at_something.emit(true)
		if lookingAtEntity.dying:
			entityEventBus.aiming_at_entity_state_changed.emit(false, null)
			lookingAtEntity = null
			isAimingAtEntity = false
		elif lookingAtEntity and not lookingAtEntity.dying:
			isAimingAtEntity = true
			entityEventBus.aiming_at_entity_state_changed.emit(true, lookingAtEntity)
		else:
			entityEventBus.aiming_at_entity_state_changed.emit(false, null)
			lookingAtEntity = null
			isAimingAtEntity = false
	
func turret_look_at(target : Vector3, by_angle : bool = false) -> void:
	if by_angle:
		turretTargetRad = target.y
		barrelTargetRad = target.x
		return
	
	var dir : Vector3 =  to_local(target).direction_to(turret.position)
	dir = dir.slide(turret.basis.y).normalized()
	
	turretTargetRad = -dir.signed_angle_to(basis.z, basis.y)
	virTurret.rotation.y = turretTargetRad

	var virBarrelRelPoint : Vector3 = virTurret.to_local(target) - virBarrel.position
	var virBarrelAngle : float = -atan(virBarrelRelPoint.y / virBarrelRelPoint.z)
	barrelTargetRad = clampf(virBarrelAngle, elevationMin, elevationMax) 

func get_aiming_position() -> Vector3:
	if barrelRay.is_colliding():
		return barrelRay.get_collision_point()
	else:
		var vector = -barrelRay.basis.z * barrelRay.target_position.length()
		return barrelRay.to_global(vector)

func get_projectile_spawn_node() -> Node3D:
	return projectileSpawn

func get_aiming_collision() -> Node3D:
	return barrelRay.get_collider()

func get_barrelRay() -> RayCast3D:
	return barrelRay

func is_aiming_at_target() -> bool:
	return is_zero_approx(turret.rotation.y - turretTargetRad) and is_zero_approx(gunBarrel.rotation.x - barrelTargetRad)

func die():
	if dying:
		return
	dying = true
	ragdoll = ragdollScene.instantiate() as RigidBody3D
	add_child(ragdoll)
	var impulsePosition : Vector3 = Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5,5))
	
	ragdoll.apply_impulse(Vector3(0.0, 5.0, 0.0),impulsePosition)
