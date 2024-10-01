extends AIState

@export var attack_state : AIState
@export var overwatch_state : AIState
@export var patrol_state : AIState

@export var overwatch_angle : float = deg_to_rad(30)
@export var wait_time : float = 3.0
@export var patrolwait_time : float = 10.0

var turningRight = true
var endState = false
var endOverwatch = false
@onready var waitTimer : Timer = $OverwatchTimer
@onready var patrolWaitTimer : Timer = $WaitTimeout

func enter():
	super()
	varStore._AIMBYANGLE = true
	varStore._TURRETLOCK = false
	varStore.AIMINGATTARGET = false
	varStore._TURRETTARGET = Vector3(0, overwatch_angle * (-1 if turningRight else 1), 0)
	patrolWaitTimer.start(patrolwait_time)

func exit():
	super()
	varStore._AIMBYANGLE = false

func process_frame(delta : float):
	if varStore.DAMAGED_:
		varStore.DAMAGED_ = false
		return attack_state
	elif endOverwatch:
		return patrol_state
	elif endState:
		endState = false
		return overwatch_state
	elif varStore.AIMINGATTARGET:
		if waitTimer.is_stopped():
			waitTimer.start(wait_time)
		return null
	
	return null
	
func _on_overwatch_timer_timeout():
	turningRight = not turningRight
	endState = true

func _on_wait_timeout_timeout():
	var endOverwatch = true
