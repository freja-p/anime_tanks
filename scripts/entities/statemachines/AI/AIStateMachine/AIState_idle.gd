extends AIState

@export var idle_time : float = 1
@onready var timer : Timer = $IdleTimer

var ready_to_continue : bool = false
var first_state : AIState

func enter():
	timer.start(idle_time)

func process_frame(delta):
	if ready_to_continue:
		return first_state
	return null

func _on_idle_timer_timeout():
	ready_to_continue = true
