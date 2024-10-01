extends VehicleState_Player

@export var stopped_state : VehicleState
@export var move_state : VehicleState


func process_physics(delta : float) -> VehicleState:
	super(delta)
	if is_zero_approx(vInput) && is_zero_approx(hInput):
		return stopped_state
	elif not is_zero_approx(vInput):
		return move_state
	
	y_rotate(hInput, delta)
	
	return null
