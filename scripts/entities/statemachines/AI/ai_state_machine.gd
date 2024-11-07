class_name AiStateMachine
extends StateMachineInterface

@export var navigator : Navigator
@export var entity : Entity_Vehicle
@export var threat_analyzer : ThreatAnalyzer

func _initialise() -> void:
	for c in get_children():
		if c is AiState:
			c.root = self
			c.navigator = navigator
			c.entity = entity
			c.threat_analyzer = threat_analyzer
