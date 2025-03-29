class_name CooldownSimple
extends CooldownInterface

var timer: Timer
var current_cooldown : float


func _ready():
	timer = Timer.new()
	timer.one_shot = true
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)


func ready_to_activate() -> bool:
	return timer.is_stopped()
	
	
func start_cooldown() -> bool:
	if not timer.is_stopped():
		return false
	
	current_cooldown = stat_calculator.get_hardpoint_stat(cooldown_resource.time_between_shots, hardpoint, Enums.HardpointStat.COOLDOWN_TIME)
	timer.start(current_cooldown)

	return true
	
	
func _on_timer_timeout() -> void:
	timer.wait_time = current_cooldown
	cooldown_ended.emit()
	
	
func get_cooldown_max() -> float:
	return current_cooldown
	
	
func get_cooldown_current() -> float:
	if timer.is_stopped():
		return current_cooldown
	return timer.time_left
