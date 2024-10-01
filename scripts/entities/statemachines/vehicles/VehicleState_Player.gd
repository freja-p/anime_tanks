class_name VehicleState_Player
extends VehicleState

static var vInput : float
static var hInput : float

static var vInputIsPositive : bool
static var hInputIsPositive : bool

func process_unhandled_input(event : InputEvent):
	var newVInput : float = Input.get_axis("move_backward","move_forward")
	var newHInput : float = Input.get_axis("move_right","move_left")
	
	if is_zero_approx(newVInput):
		pass
	elif newVInput  > 0:
		vInputIsPositive = true
	else:
		vInputIsPositive = false
	
	if is_zero_approx(newHInput):
		pass
	elif newHInput > 0:
		hInputIsPositive = true
	else:
		hInputIsPositive = false
	
	vInput = newVInput
	hInput = newHInput

	return null
