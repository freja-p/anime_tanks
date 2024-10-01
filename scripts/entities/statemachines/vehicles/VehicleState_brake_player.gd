extends VehicleState_Player

@export var stopped_state : VehicleState
@export var move_state : VehicleState

func enter() -> void:
	pass
	
func exit() -> void:
	pass

func process_physics(delta : float) -> VehicleState:
	super(delta)

	if not is_zero_approx(vInput):
		return move_state
	elif is_zero_approx(locVelocity.length()):
		return stopped_state
	
	y_rotate(hInput, delta)
	apply_enginebrake(delta)
	return null
