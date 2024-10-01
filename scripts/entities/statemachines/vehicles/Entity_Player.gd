class_name Entity_Player
extends Entity

@export_category("Stats")
@export var maxHP : float = 100
@export var mainAbility : Ability
@export var secondaryAbility : Ability
@export var defensiveAbility : Ability
var currHP : float 

@export_category("Gunnery")
# Movement
var vInput : float
var hInput : float
@onready var vehicleBody : VehicleBody = $Body as VehicleBody
@onready var controller : VehicleFSM = $VehicleControllerFSM as VehicleFSM
var fsmVars : Dictionary

var locVelocity : Vector3
var grounded : bool

# Turret Aiming
var rotateTurretTarget : Vector3

# Gun System
@onready var reloadTimer : Timer = $ShootTimer
var hardPoints : Array[Node3D] = []
var defensive : AbilityExecutor
var mainGun : AbilityExecutor
var secondaryhp : AbilityExecutor

# UI Processing
signal aim_position_update(worldPosition : Vector3)
var barrelRayEnd : Node3D

# Debug vars
#var applyingforces : bool
#var aimIndicator : Node3D

func _ready():
	fsmVars = controller.init(self)
	fsmVars[VehicleState.VEHVARS.GROUNDED] = false
	controller.start_fsm()
	
	vehicleBody.initialise(self, vehicleStats)

	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = to_local(vehicleBody.centerVector)
	
	currHP = maxHP
	
#	This should grab all turret hardpoints (Excluding main gun) at some point
#	hardPoints.append(turretMesh.get_projectile_spawn_node())
	hardPoints.append_array($Hardpoints.get_children())
	
	defensive = _init_ability(defensiveAbility, $Hardpoints/Internal)
	secondaryhp = _init_ability(secondaryAbility, $Hardpoints/RearDeck)
	mainGun = _init_ability(mainAbility, turretMesh.get_projectile_spawn_node())
	CameraEventBus.player_cam_camera_rotated.connect(_on_player_cam_camera_rotated)

func _integrate_forces(state : PhysicsDirectBodyState3D):
#	move_player(state)
#	rotate_turret(state)
	controller.integrate_forces(state)
	pass

func _physics_process(delta):
	grounded = vehicleBody.update_suspension(self, delta, Quaternion(transform.basis))
	fsmVars[VehicleState.VEHVARS.GROUNDED] = grounded
#	VehicleState.grounded = grounded
	controller.process_physics(delta)
	
	var speed = linear_velocity.project(to_global(-basis.z)).length()
	var vAngle = (-basis.z).angle_to(linear_velocity)
	if vAngle > PI/2:
		speed *= -1
		
	vehicleBody.update_wheel_speed(self)
	pass

func _process(delta):
	controller.process_frame(delta)
	pass

func _unhandled_input(event : InputEvent):
	if event.is_action("primary_attack"):
		mainGun.activate(event.is_pressed())
	if event.is_action("defensive_ability"):
		defensive.activate(event.is_pressed())
	if event.is_action("secondary_attack"):
		secondaryhp.activate(event.is_pressed())
		
	controller.process_unhandled_input(event)
	
func get_target_point() -> Vector3:
	return turretMesh.get_aiming_position()
	
func alert(entity : Entity):
	return

func rotate_turret():
	turretMesh.aim_at(rotateTurretTarget)
	
	var aimPosition : Vector3
	aimPosition = turretMesh.get_aiming_position()
	
#	aimIndicator.global_position = aimPosition
	aim_position_update.emit(aimPosition)
	PlayerEventBus.turret_aiming_updated.emit(aimPosition)
	
func _on_player_cam_camera_rotated(worldPosition):
	rotateTurretTarget = worldPosition
	rotate_turret()

func get_locVelocity():
	return linear_velocity
	
func get_grounded():
	return grounded

func hit(collider : Node3D, base_damage : float, shooter : Node3D):
	var damage = base_damage
	if collider.name == "TurretHitbox":
		damage *= 1.3
		
	currHP = currHP - damage
	
	if currHP < 0:
		currHP = maxHP
		print("dead")
