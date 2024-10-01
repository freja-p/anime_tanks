extends VehicleState

@export var idle_state : VehicleState
@export var turn_state : VehicleState
@export var brake_state : VehicleState

func process_physics(delta : float) -> VehicleState:
	super(delta)
	
	if stateVarStore[VEHVARS.STOP_]:
		return brake_state
	
	var currentTarget = stateVarStore[VEHVARS.CURRENTTARGET]
	var finalTarget = stateVarStore[VEHVARS.FINALTARGET]
	var vectorToTarget : Vector3 = parentNode.global_position.direction_to(currentTarget)
	var angleToTarget : float = (-parentNode.basis.z).signed_angle_to(vectorToTarget, Vector3.UP)
	
	if abs(angleToTarget) > deg_to_rad(vehicleStats.moveAndTurnThresholdDegrees):
		return turn_state
	elif abs(angleToTarget) > deg_to_rad(vehicleStats.maxAngleThreshold):
		if angleToTarget > 0:
			y_rotate(speedRatio, delta)
		else:
			y_rotate(-speedRatio, delta)
	
	var brakeDistance : float = calculate_braking_distance()
	var distanceToTarget : float = parentNode.global_position.distance_to(finalTarget)
	if distanceToTarget < brakeDistance:
		return brake_state

	z_move(speedRatio, delta)
	
	return null
