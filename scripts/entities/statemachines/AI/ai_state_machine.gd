class_name AiStateMachine
extends StateMachineInterface

@export var navigator : Navigator
@export var entity : Entity_Vehicle

enum AiVars {
	NAVIGATOR
}

func _ready() -> void:
	blackboard.set_variable(AiVars.NAVIGATOR, navigator)
