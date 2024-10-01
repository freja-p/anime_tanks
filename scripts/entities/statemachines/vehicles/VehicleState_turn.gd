extends VehicleState

@export var move_state : VehicleState
@export var idle_state : VehicleState
@export var brake_state : VehicleState

var lastAngle : float = 10.0

func process_physics(delta : float):
	super(delta)
	var currentTarget = stateVarStore[VEHVARS.CURRENTTARGET]
	var vectorToTarget : Vector3 = parentNode.global_position.direction_to(currentTarget)
	var angleToTarget : float = (-parentNode.basis.z).signed_angle_to(vectorToTarget, Vector3.UP)
	
	var distanceToFinalTarget : float = parentNode.global_position.distance_to(stateVarStore[VEHVARS.FINALTARGET])
	if distanceToFinalTarget < vehicleStats.targetDistanceThreshold:
		stateVarStore[VEHVARS.TARGETREACHED] = true
		return idle_state
	
	elif abs(angleToTarget) < deg_to_rad(vehicleStats.maxAngleThreshold):
		return move_state
	
	elif abs(angleToTarget) < deg_to_rad(vehicleStats.moveAndTurnThresholdDegrees):
		var brakeDistance : float = calculate_braking_distance()
		if distanceToFinalTarget < brakeDistance:
			return brake_state
			
		if angleToTarget > 0:
			y_rotate(speedRatio, delta)
		else:
			y_rotate(-speedRatio, delta)
			
		z_move(speedRatio, delta)
	else:
		if angleToTarget > 0:
			y_rotate(speedRatio, delta)
		else:
			y_rotate(-speedRatio, delta)
	return null
