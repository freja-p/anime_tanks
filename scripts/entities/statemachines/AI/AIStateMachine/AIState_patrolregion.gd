extends AIState

@export var attack_state : AIState
@export var patrol_state : AIState
@export var patrolWait_state : AIState

var readyFrames : int
var patrolIdx : int = 0

func enter():
	super()
	varStore._NEWTARGET_ = true
	varStore._FINALTARGET = calculate_new_target()

func process_frame(delta : float) -> AIState:
	if varStore.DAMAGED_:
		varStore.DAMAGED_ = false
		varStore._STOP_ = true
		return attack_state
		
	elif varStore.TARGETREACHED_:
		varStore.TARGETREACHED_ = false
		return patrolWait_state
	return null

func calculate_new_target() -> Vector3:
	var newPoint : Vector3 = aiStats.patrolRegionCenter[0]
	
	# https://stackoverflow.com/questions/5837572/generate-a-random-point-within-a-circle-uniformly
	var randRadius : float = aiStats.patrolRegionRadius[0] * sqrt(randf())
	var randAngle : float = randf() * 2 * PI
	
	newPoint.x = newPoint.x + randRadius * cos(randAngle)
	newPoint.z = newPoint.z + randRadius * sin(randAngle)
	
	return newPoint
	
