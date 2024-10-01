class_name VehicleState
extends Node

var parentNode : RigidBody3D
var vehicleStats : VehicleStats

var neutral : bool = true 
var locVelocity : Vector3 = Vector3.ZERO

var turning : bool = false
var braking : bool = false

var speedRatio : float = 1.0
var currentFrictionAccel : Vector3
var leftPowerPercent : float
var rightPowerPercent : float
var stateVarStore : Dictionary

enum VEHVARS {GROUNDED, 
TARGETREACHED, 
CURRENTTARGET, 
FINALTARGET, 
NEWTARGET, 
STOP_}

func enter() -> void:
#	print("Veh: %s" % self.name)
	pass

func exit() -> void:
	pass

func process_frame(delta : float) -> VehicleState:
	return null

func process_physics(delta : float) -> VehicleState:
	neutral = true
	locVelocity = parentNode.linear_velocity
#	stateVarStore[VEHVARS.CURRENTTARGET].y = parentNode.global_position.y
	
	apply_lateral_friction(delta)
	return null

func integrate_forces(state : PhysicsDirectBodyState3D) -> VehicleState:
	return null
	
#region Apply movements
func z_move(forceRatio : float, delta : float):
	# Apply force if the tank is grounded and not moving at maximum speed.
	if not is_zero_approx(forceRatio) && stateVarStore[VEHVARS.GROUNDED]:
		neutral = false
		if locVelocity.length() < vehicleStats.maxSpeed && locVelocity.length() > -vehicleStats.maxSpeed:
			parentNode.apply_force(-parentNode.basis.z * forceRatio * vehicleStats.accel * parentNode.mass, parentNode.center_of_mass + Vector3(0.0, vehicleStats.forceYOffset, 0.0))

func brake(force: float, delta : float):
	if not is_zero_approx(force) && stateVarStore.grounded:
		neutral = false
	if locVelocity.length() < vehicleStats.maxSpeed && locVelocity.length() > -vehicleStats.maxSpeed:
		parentNode.apply_central_force(parentNode.basis.z * force * vehicleStats.accel * parentNode.mass)

func y_rotate(torqueRatio : float, delta : float):
	# Apply torque when the tank is grounded and not turning at maximum speed. 
	# Also set neutral to false because the tracks have power.
	if not is_zero_approx(torqueRatio) && stateVarStore[VEHVARS.GROUNDED]:
		neutral = false
		if parentNode.angular_velocity.length() < vehicleStats.maxTurnRate:
			
			parentNode.apply_torque(parentNode.basis.y * torqueRatio * vehicleStats.angularAccel * parentNode.mass)

func z_move_power(inputPower : float, delta : float):
	# Apply force if the tank is grounded and not moving at maximum speed.
	var outputPower : float = inputPower
	if locVelocity.length() < vehicleStats.maxSpeed && stateVarStore[VEHVARS.GROUNDED]:
		leftPowerPercent = outputPower / 2
		rightPowerPercent = outputPower / 2
	else:
		leftPowerPercent = 0
		rightPowerPercent = 0

func y_rotate_power(inputPower : float, delta : float):
	var forceOffset : Vector3 = Vector3(0.0, vehicleStats.forceYOffset, 0.0)
	if inputPower < 0:
		leftPowerPercent *= 0.25
		rightPowerPercent *= 2
	elif inputPower > 0:
		leftPowerPercent *= 2
		rightPowerPercent *= 0.25

func apply_track_power(delta : float):
#	if grounded && locVelocity.project(-parentNode.basis.z).length() < vehicleStats.maxSpeed:
	if stateVarStore[VEHVARS.GROUNDED]:
		neutral = false
		parentNode.apply_force(-parentNode.basis.z * leftPowerPercent * vehicleStats.accel * parentNode.mass, parentNode.center_of_mass + Vector3(vehicleStats.forceXOffset, vehicleStats.forceYOffset, 0.0))
		parentNode.apply_force(-parentNode.basis.z * rightPowerPercent* vehicleStats.accel * parentNode.mass, parentNode.center_of_mass + Vector3(-vehicleStats.forceXOffset, vehicleStats.forceYOffset, 0.0))

func apply_lateral_friction(delta : float):
	# Calculate friction force applied according to the difference between local velocity and forward direciton.
	# The more we are sliding sideways, the more friction force is applied. 
	# This is done to simulate the tracks rolling freely when no power is applied to them.
	var frictionAccel : float
	var frictionAngle = (-parentNode.basis.z).angle_to(locVelocity)
	
	if frictionAngle < PI/2:
		frictionAccel = frictionAngle
	else:
		frictionAccel = abs(frictionAngle - PI)
#	if locVelocity.length() > 0.5 && grounded:
	if stateVarStore[VEHVARS.GROUNDED]:
		var d = -locVelocity.project(-parentNode.basis.x).normalized()
		currentFrictionAccel = d * frictionAccel * vehicleStats.frictionMult
#		print("friction: %s" % currentFrictionAccel)
		parentNode.apply_central_force(currentFrictionAccel * parentNode.mass)
		
	parentNode.apply_torque(-parentNode.angular_velocity * vehicleStats.angularDrag * parentNode.mass)
#endregion

func apply_enginebrake(delta : float):
	if stateVarStore[VEHVARS.GROUNDED]:
		var d = -locVelocity.project(-parentNode.to_global(parentNode.basis.z)).normalized()
		parentNode.apply_central_force(d * vehicleStats.engineBrakeAccel * parentNode.mass)

func calculate_braking_distance() -> float:
#	print((pow(locVelocity.length(), 2)) / (2.0 * (vehicleStats.brakeAccel)))
	return (pow(locVelocity.length(), 2)) \
	/ (2.0 * (vehicleStats.brakeAccel))
	
func calculate_brake_deceleration(distance : float) -> float:
	return pow(locVelocity.length(),2) / (2.0 * distance)
