class_name VehicleFSM
extends Node

@export var startingState : VehicleState
var currentState : VehicleState

func init(parent : RigidBody3D) -> Dictionary:
	var fsmVars : Dictionary
	fsmVars[VehicleState.VEHVARS.GROUNDED] = false
	fsmVars[VehicleState.VEHVARS.TARGETREACHED] = false
	fsmVars[VehicleState.VEHVARS.NEWTARGET] = false
	fsmVars[VehicleState.VEHVARS.STOP_] = false
	fsmVars[VehicleState.VEHVARS.CURRENTTARGET] = parent.global_position
	
	for child in get_children():
		if child is VehicleState:
			child.parentNode = parent
			child.vehicleStats = $VehicleStats as VehicleStats
			child.stateVarStore = fsmVars

	return fsmVars

func start_fsm() -> void:
	change_state(startingState)

func change_state(newState : VehicleState) -> void:
	if currentState:
		currentState.exit()

	currentState = newState
	currentState.enter()
	
func process_physics(delta: float) -> void:
	var new_state = currentState.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_input(event: InputEvent) -> void:
	var new_state = currentState.process_input(event)
	if new_state:
		change_state(new_state)

func process_unhandled_input(event : InputEvent) -> void:
	var newState = currentState.process_unhandled_input(event)
	if newState:
		change_state(newState)

func process_frame(delta : float) -> void:
	var newState = currentState.process_frame(delta)
	if newState:
		change_state(newState)
		
func integrate_forces(state : PhysicsDirectBodyState3D) -> void:
	var newState = currentState.integrate_forces(state)
	if newState:
		change_state(newState)
