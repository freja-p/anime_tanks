class_name StateInterface
extends Node

var root_statemachine : StateMachineInterface
var parent_statemachine : StateMachineInterface
var tick_process_timer : Timer

func _ready() -> void:
	parent_statemachine = get_parent() as StateMachineInterface


func initialise() -> void:
	_initialise()
	for c in get_children():
		if c is StateInterface:
			c.root_statemachine = root_statemachine
			c.initialise()
	
	
func process_tick(_delta : float) -> void:
	_on_tick(_delta)


func change_state(new_state : StateInterface) -> void:
	parent_statemachine.change_state(new_state)
	
	
func exit_state() -> void:
	parent_statemachine.change_state(null)
	
	
func _initialise() -> void:
	pass
	
	
func _enter_state() -> void:
	pass


func _exit_state() -> void:
	pass
	
	
func _on_tick(_delta : float) -> void:
	return 
	
