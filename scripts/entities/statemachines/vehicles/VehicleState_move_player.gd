extends VehicleState_Player

@export var brake_state : VehicleState

var lastVInputPositive : bool

func enter() -> void:
	pass
	
func exit() -> void:
	pass

func process_physics(delta : float) -> VehicleState:
	super(delta)
	
	if is_zero_approx(vInput):
		return brake_state
	
	z_move(vInput, delta)
	y_rotate(hInput, delta)
	
	return null
