extends Node
class_name VehicleController_Tank
@export_category("Movement")
@export var accel : int = 15
@export var maxSpeed : int = 10
@export var frictionMult : int = 2
@export var brakeForce : int = 15 # Braking breaks when this value is too high for some reason

@export var maxTurnRate : int = 1
@export var angularAccel : int = 50
@export var angularDrag : int = 20

@onready var parentBody : RigidBody3D = get_parent()
@onready var grounded : bool = parentBody.get_node("GroundCasts").is_grounded()
var neutral : bool = true 
var locVelocity : Vector3 = Vector3.ZERO
var applyingforces : bool = false

var currentTarget : Vector3
var turning : bool = false
var targetReached : bool = false
var braking : bool = false

signal vehicleReachedTarget

func _ready():
	parentBody.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	parentBody.linear_damp = 0

func move(targetPos : Vector3, speedRatio : float, moveAndTurnThresholdDegrees : float, state : PhysicsDirectBodyState3D) -> void:
	grounded = parentBody.get_node("GroundCasts").is_grounded()
	neutral = true 
	locVelocity = state.linear_velocity
	applyingforces = false
	
	targetPos.y = parentBody.global_position.y
	var vectorToTarget : Vector3 = parentBody.global_position.direction_to(targetPos)
	var angleToTarget : float = (-parentBody.basis.z).signed_angle_to(vectorToTarget, Vector3.UP)

	var meshNode : Node3D = get_parent().get_node("Mesh/Body/Turret")
	meshNode.look_at(targetPos)
	meshNode.rotation.x = 0

	var distanceToTarget : float = parentBody.global_position.distance_to(targetPos)
	if not targetReached and abs(angleToTarget) > deg_to_rad(1):
		turning = true
		if angleToTarget > 0:
			y_rotate(speedRatio, state)
		else:
			y_rotate(-speedRatio, state)
	else:
		turning = false
	
#	print("V: %f | Braking Distance: %f | d: %f | b? : %s" % 
#	[locVelocity.length(),calculate_braking_distance(), distanceToTarget, distanceToTarget < calculate_braking_distance()])
	
	var brakeDistance : float = calculate_braking_distance()
	if abs(angleToTarget) < deg_to_rad(moveAndTurnThresholdDegrees) and distanceToTarget > 2:
		if distanceToTarget < brakeDistance:
			braking = true
			brake(brakeForce, state)
		elif braking == false:
			z_move(speedRatio, state)
	elif distanceToTarget < 2:
		if not targetReached:
			vehicleReachedTarget.emit()
		
		braking = false
		targetReached = true
		
	if locVelocity.length() > 0.3:
		apply_friction(state)

func calculate_braking_distance() -> float:
	return pow(locVelocity.length(), 2) / (2 * brakeForce)

#region Apply movements

func z_move(forceRatio : float, state : PhysicsDirectBodyState3D):
	# Apply force if the tank is grounded and not moving at maximum speed.
	if not is_zero_approx(forceRatio) && grounded:
		neutral = false
		if locVelocity.length() < maxSpeed && locVelocity.length() > -maxSpeed:
			applyingforces = true
			state.apply_central_force(-parentBody.basis.z * forceRatio * accel)

func brake(force: float, state : PhysicsDirectBodyState3D):
	if not is_zero_approx(force) && grounded:
		neutral = false
	if locVelocity.length() < maxSpeed && locVelocity.length() > -maxSpeed:
		applyingforces = true
		state.apply_central_force(parentBody.basis.z * force * accel)

func y_rotate(torqueRatio : float, state : PhysicsDirectBodyState3D):
		# Apply torque according to horizontal input when the tank is grounded and not turning at maximum speed. 
	# Also set neutral to false because the tracks have power.
	if not is_zero_approx(torqueRatio) && grounded:
		neutral = false
		if state.angular_velocity.length() < maxTurnRate:
			applyingforces = true
			state.apply_torque(parentBody.basis.y * torqueRatio * angularAccel)
	else:
		state.apply_torque(-state.angular_velocity * angularDrag)
	
func apply_friction(state : PhysicsDirectBodyState3D):
	# Calculate friction force applied according to the difference between local velocity and forward direciton.
	# The more we are sliding sideways, the more friction force is applied. 
	# This is done to simulate the tracks rolling freely when no power is applied to them.
	var frictionForce : float
	var frictionAngle = (-parentBody.basis.z).angle_to(locVelocity)

	if frictionAngle < PI/2:
		frictionForce = frictionAngle
	else:
		frictionForce = abs(frictionAngle - PI)
		
	if locVelocity.length() > 0.5 && grounded:
		var d = -locVelocity.normalized()
		state.apply_central_force(d * frictionForce * frictionMult)

#endregion

func _on_enemy_new_target_calculated():
	targetReached = false
