extends StateInterface

@export var combat_state : StateInterface

var has_been_hit : bool


func _enter_state():
	has_been_hit = false
	

func _on_tick(_delta : float):
	if has_been_hit:
		change_state(combat_state)
