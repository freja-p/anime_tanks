extends AIState

@export var move_state : AIState


func process_frame(delta : float) -> AIState:
	var newTarget = Vector3(100.0, 100.0, 100.0)
	var navigator : NavigationAgent3D = varStore.NAVIGATOR
	
	navigator.target_position = newTarget
	if not navigator.is_target_reachable():
		newTarget = Vector3(randf_range(-aiStats.maxRange.x, aiStats.maxRange.x), 0, randf_range(-aiStats.maxRange.y,aiStats.maxRange.y))
		navigator.target_position = newTarget
	
#	print("New target calculated %s" % newTarget)
	varStore._FINALTARGET = newTarget
	return move_state
