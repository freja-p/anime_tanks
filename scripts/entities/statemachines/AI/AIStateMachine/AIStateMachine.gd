class_name StateMachine
extends Node

@export var startingState : AIState
@export var entityEventBus : EntityEventBus
var currentState : AIState

func init(parent : Entity, navAgent : NavigationAgent3D, stateVars : AIVariableStore, patrolBehaviours : Array[AI_PatrolPathRegion_R]):
	stateVars._FINALTARGET = parent.global_position
	stateVars.NAVIGATOR = navAgent
	stateVars.CURRENTBEHAVIOUR = patrolBehaviours[0]
	stateVars.PATROLBEHAVIOURS = patrolBehaviours
	stateVars.TARGETREACHED_ = false
	var aiStats : AIStats = $AIStats as AIStats
	
	for child in get_children():
		if child is AIState:
			child.aiStats = aiStats
			child.varStore = stateVars
			child.parentEntity = parent
			
		if child.name == "idle":
			child.first_state = startingState
			startingState = child
	return 

func start_fsm() -> void:
	change_state(startingState)

func change_state(newState : AIState) -> void:
	if currentState:
		currentState.exit()

	currentState = newState
	currentState.enter()
	
func process_physics(delta: float) -> void:
	var new_state = currentState.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_frame(delta : float) -> void:
	var newState = currentState.process_frame(delta)
	if newState:
		change_state(newState)
		
func integrate_forces(state : PhysicsDirectBodyState3D) -> void:
	var newState = currentState.integrate_forces(state)
	if newState:
		change_state(newState)
