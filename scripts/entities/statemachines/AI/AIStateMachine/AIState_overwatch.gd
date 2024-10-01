extends AIState

@export var attack_state : AIState
@export var overwatch_state : AIState
@export var patrol_state : AIState

var currentBehaviour : AI_PatrolPathRegion_R
var overwatch_angle : float
var wait_time : float

var turningRight = true
var endState = false

var endOverwatch = false

@onready var aim_swing_timer : Timer = %AimSwingTimer
@onready var overwatch_timeout : Timer = %OverwatchTimeout


func enter():
	super()
	varStore._AIMBYANGLE = true
	varStore._TURRETLOCK = false
	varStore.AIMINGATTARGET = false
	varStore._TURRETTARGET = Vector3(0, overwatch_angle * (-1 if turningRight else 1), 0)
	
	currentBehaviour = varStore.CURRENTBEHAVIOUR
	if currentBehaviour.overwatchDuration > 0 and overwatch_timeout.is_stopped():
		overwatch_timeout.start(currentBehaviour.overwatchDuration)

	overwatch_angle = deg_to_rad(currentBehaviour.overwatchAngleDegrees)

func exit():
	super()
	varStore._AIMBYANGLE = false

func process_frame(delta : float):
	if varStore.ALERT_:
		varStore.ALERT_ = false
		return attack_state
	elif endOverwatch:
		endOverwatch = false
		return patrol_state
	elif endState:
		endState = false
		return overwatch_state
	
	if varStore.AIMINGATTARGET:
		if aim_swing_timer.is_stopped():
			aim_swing_timer.start()

	return null

func _on_aim_swing_timer_timeout():
	turningRight = not turningRight
	endState = true


func _on_overwatch_timeout_timeout():
	endOverwatch = true
