extends VehicleState_Player

@export var move_state : VehicleState
@export var rotate_state : VehicleState

func enter() -> void:
	pass
	
func exit() -> void:
	pass

func process_physics(delta : float) -> VehicleState:
	super(delta)
	apply_enginebrake(delta)
	if is_zero_approx(vInput) && is_zero_approx(hInput):
		return null
	elif is_zero_approx(vInput) && not is_zero_approx(hInput):
		return rotate_state
	else:
		return move_state
