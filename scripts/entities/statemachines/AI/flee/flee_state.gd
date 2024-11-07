class_name FleeState
extends AiState

@export var flee_state_threshold : float = 0.5

func _enter_state() -> void:
	navigator.navigation_finished.connect(_on_navigation_finished)
	navigator.navigate_to(pick_random_destination()) 


func _exit_state() -> void:
	navigator.navigation_finished.disconnect(_on_navigation_finished)
	

func _on_navigation_finished() -> void:
	navigator.navigate_to(pick_random_destination(entity.global_position, 50, 20)) 
	return
