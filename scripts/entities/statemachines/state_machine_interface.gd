class_name StateMachineInterface
extends StateInterface

@export var starting_state : StateInterface
@export var tick_duration : float = 0.1
@export var autostart : bool = true

var current_state : StateInterface


func _ready() -> void:
	if not autostart:
		return
		
	super()
	
	if not parent_statemachine:
		root_statemachine = self
		initialise_statemachine_root()
		

func start() -> void:
	_ready()

func initialise_statemachine_root() -> void:
	initialise()
	tick_process_timer = Timer.new()
	add_child(tick_process_timer)
	tick_process_timer.one_shot = false
	tick_process_timer.timeout.connect(process_tick.bind(tick_duration))
	
	if autostart:
		tick_process_timer.start(tick_duration)
		
	change_state(starting_state)


func change_statemachine(new_state : StateInterface) -> void:
	parent_statemachine.change_state(new_state)


func change_state(new_state : StateInterface) -> void:
	if current_state:
		current_state._exit_state()
	
	if not new_state:
		_exit_state_machine()
	
	print("AI State transition %s -> %s " % [current_state, new_state])
	
	current_state = new_state
	current_state._enter_state()


func process_tick(_delta : float) -> void:
	current_state.process_tick(_delta)
	_on_tick(_delta)
	
	
func _exit_state_machine() -> void:
	return
