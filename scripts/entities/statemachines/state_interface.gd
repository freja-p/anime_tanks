class_name StateInterface
extends Node

var parent_statemachine : StateMachineInterface
var blackboard : VariableStore


func _ready() -> void:
	parent_statemachine = get_parent() as StateMachineInterface
	for c in get_children():
		c.blackboard = blackboard
	
	
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
	
