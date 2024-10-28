class_name StateMachineInterface
extends StateInterface

@export var starting_state : StateInterface
@export var tick_duration : float = 0.1

var current_state : StateInterface

func _ready() -> void:
	super()
	
	var timer : Timer = Timer.new()
	add_child(timer)
	timer.one_shot = false
	timer.timeout.connect(process_tick.bind(tick_duration))
	timer.start(tick_duration)
	
func _exit_state_machine() -> void:
	return

func change_statemachine(new_state : StateInterface) -> void:
	parent_statemachine.change_state(new_state)

func change_state(new_state : StateInterface) -> void:
	if current_state:
		current_state.exit()
	
	if not new_state:
		_exit_state_machine()

	current_state = new_state
	current_state.enter()

func process_tick(_delta : float) -> void:
	current_state.process_tick(_delta)
	_on_tick(_delta)
