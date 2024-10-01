extends AIState

@export var attack_state : AIState
@export var patrol_state : AIState
@export var overwatch_state : AIState

var readyFrames : int
var behaviourIdx : int = 0
var pathIndex : int = 0

var endOfBehaviour : bool
var isReset : bool = false

func enter():
	super()
	var newPosition : Vector3 = get_next_point()
	varStore.new_target_position.emit(newPosition)
#	varStore._FINALTARGET = newPosition
	varStore._TURRETLOCK = true
	
func exit():
	super()

func process_frame(delta : float) -> AIState:
	if varStore.ALERT_:
		varStore.ALERT_ = false
		varStore.stop.emit()
		return attack_state
		
	elif varStore.TARGETREACHED_:
#		print("AI Ctrl: Target Reached")
		varStore.TARGETREACHED_ = false
		pathIndex += 1
		if varStore.CURRENTBEHAVIOUR.overwatchAfterEachPath or (endOfBehaviour and varStore.CURRENTBEHAVIOUR.overwatchAfterEndOfPath):
			endOfBehaviour = false
			return overwatch_state
		else:	
			return patrol_state
	return null

func get_next_point() -> Vector3:
	if not varStore.CURRENTBEHAVIOUR.is_index_valid(pathIndex):
		switch_behaviour(behaviourIdx + 1)
		pathIndex = 0

	var nextPoint = varStore.CURRENTBEHAVIOUR.get_point(pathIndex)
	var navAgent : NavigationAgent3D = varStore.NAVIGATOR
	
	if varStore.CURRENTBEHAVIOUR.patrolRelativeToPosition:
		nextPoint += varStore.GLOBALPOSITION
		pass
	
	if varStore.CURRENTBEHAVIOUR.radius > 0:
		while not navAgent.is_target_reachable():
			nextPoint = varStore.CURRENTBEHAVIOUR.get_point(pathIndex)
		
	return nextPoint
	
func switch_behaviour(index : int) -> void:
	var patrolBehaviours : Array[AI_PatrolPathRegion_R] = varStore.PATROLBEHAVIOURS
	if index >= patrolBehaviours.size():
		isReset = true
		index = 0
		
	elif index < 0:
		index = patrolBehaviours.size() - 1
	
	endOfBehaviour = true
	varStore.CURRENTBEHAVIOUR = patrolBehaviours[index]
