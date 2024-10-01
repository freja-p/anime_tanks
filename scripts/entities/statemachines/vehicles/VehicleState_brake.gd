extends VehicleState

@export var idle_state : VehicleState
@export var turn_state : VehicleState

func process_physics(delta : float) -> VehicleState:
	super(delta)
	var distanceToTarget = parentNode.global_position.distance_to(stateVarStore[VEHVARS.FINALTARGET])
#	print("D: %f | V: %f A: %f" % [distanceToTarget, locVelocity.length(), locVelocity.angle_to(-parent.basis.z)])
	if (stateVarStore[VEHVARS.STOP_] or stateVarStore[VEHVARS.TARGETREACHED]) and locVelocity.length() < 1.0:
		stateVarStore[VEHVARS.TARGETREACHED] = false
		stateVarStore[VEHVARS.STOP_] = false
		return idle_state
	elif not stateVarStore[VEHVARS.STOP_] and not stateVarStore[VEHVARS.TARGETREACHED] and locVelocity.length() < 1.0:
		return turn_state
	else:
		if stateVarStore[VEHVARS.GROUNDED]:
#		#print("Braking %s" % (parentNode.basis.z * parentNode.mass * vehicleStats.brakeAccel))
			parentNode.apply_central_force(parentNode.basis.z * parentNode.mass * vehicleStats.brakeAccel)
		return null
		
#	if stateVarStore[VEHVARS.STOP_]:
#		if locVelocity.length() < 1.0:
#			stateVarStore[VEHVARS.STOP_] = false
#			stateVarStore[VEHVARS.TARGETREACHED] = true
#			return idle_state
#	elif locVelocity.angle_to(-parentNode.basis.z) > PI/2: # Stop applying all forces once vehicle is reversing
#		stateVarStore[VEHVARS.TARGETREACHED] = true
#		return idle_state
#	elif distanceToTarget < vehicleStats.targetDistanceThreshold and locVelocity.length() < 1.0:
#		stateVarStore[VEHVARS.TARGETREACHED] = true
#		return idle_state
#	elif distanceToTarget > vehicleStats.targetDistanceThreshold and locVelocity.length() < vehicleStats.minSpeed:
#		return turn_state
		
#	var brakingDistance = calculate_braking_distance()

	if stateVarStore[VEHVARS.GROUNDED]:
#		#print("Braking %s" % (parentNode.basis.z * parentNode.mass * vehicleStats.brakeAccel))
		parentNode.apply_central_force(parentNode.basis.z * parentNode.mass * vehicleStats.brakeAccel)
	
	return null
