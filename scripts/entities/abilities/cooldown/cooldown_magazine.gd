class_name CooldownMagazine
extends CooldownInterface

signal current_ammo_updated(count : int)
signal reload_started

var ammo_count : int
var ammo_max : int
var timer: Timer


func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	ammo_count = stat_calculator.get_hardpoint_stat(cooldown_resource.magazine_size, hardpoint, Enums.HardpointStat.MAX_AMMO)
	ammo_max = stat_calculator.get_hardpoint_stat(cooldown_resource.magazine_size, hardpoint, Enums.HardpointStat.MAX_AMMO)


func ready_to_activate() -> bool:
	return timer.is_stopped()
	
	
func start_cooldown() -> bool:
	if not timer.is_stopped():
		return false
	
	ammo_count -= 1

	current_ammo_updated.emit(ammo_count)
	if ammo_count > 0:
		timer.start(stat_calculator.get_hardpoint_stat(cooldown_resource.time_between_shots, hardpoint, Enums.HardpointStat.COOLDOWN_TIME))
	else:
		reload_started.emit()
		timer.start(stat_calculator.get_hardpoint_stat(cooldown_resource.time_to_reload, hardpoint, Enums.HardpointStat.COOLDOWN_TIME))
	return true
	
	
func _on_timer_timeout() -> void:
	if ammo_count <= 0:
		ammo_max = stat_calculator.get_hardpoint_stat(cooldown_resource.magazine_size, hardpoint, Enums.HardpointStat.MAX_AMMO)
		ammo_count = ammo_max
	cooldown_ended.emit()
	
	
func get_cooldown_max() -> float:
	return ammo_max
	
	
func get_cooldown_current() -> float:
	return ammo_count
