extends VehicleState

@export var turn_state : VehicleState

#func exit():
#	super()
#	stateVarStore[VEHVARS.TARGETREACHED] = false

func process_frame(delta : float) -> VehicleState:
	if stateVarStore[VEHVARS.NEWTARGET]:
		stateVarStore[VEHVARS.NEWTARGET] = false
		return turn_state
	else:
		return null

func process_physics(delta : float) -> VehicleState:
	super(delta)
	apply_enginebrake(delta)
	return null
