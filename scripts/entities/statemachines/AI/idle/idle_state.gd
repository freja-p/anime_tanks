extends AiState

@export_category("State Transitions")
@export var attack_state : AttackState
@export var flee_state : FleeState
@export_category("State Variables")

var has_been_hit : bool

func _enter_state():
	threat_analyzer.threat_target_changed.connect(_on_threat_updated)
	has_been_hit = false
	

func _exit_state():
	has_been_hit = false


func _on_tick(_delta : float):
	if has_been_hit:
		change_state(attack_state)
	
	if entity.health_manager.get_health_percent() < flee_state.flee_state_threshold:
		change_state(flee_state)


func _on_threat_updated(entity : Entity):
	has_been_hit = true
