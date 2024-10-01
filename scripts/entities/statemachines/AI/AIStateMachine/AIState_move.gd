extends AIState

@export var attack_state : AIState
@export var patrol_state : AIState
var readyFrames : int

func enter():
	super()
	varStore._NEWTARGET_ = true

func process_frame(delta : float) -> AIState:
	if varStore.TARGETREACHED_:
		varStore.TARGETREACHED_ = false
#		print("target reached")
		return attack_state
	return null
