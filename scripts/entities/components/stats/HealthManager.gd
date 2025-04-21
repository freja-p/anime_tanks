class_name HealthManager
extends Node

## Entity Component for tracking and applying damage taken

signal damage_taken(damage : float)

const dot_timer_tick_rate : float = 0.25

@export var owner_entity : Entity
@export var modifier_handler : ModifierHandler
@export var health_restore_delay : float = 3
@export var health_restore_rate : float = 10

var max_health : float
var current_health : float = 100
var dot_effects : Dictionary

@onready var dot_ticker: Timer = $DotTicker
@onready var health_restore_timer: Timer = $HealthRestoreTimer


func _ready() -> void:
	modifier_handler.modifier_added.connect(_on_modifier_added)
	modifier_handler.modifier_removed.connect(_on_modifier_removed)
	max_health = get_parent().health
	current_health = max_health
	

func hurt(damage_amount : float) -> float:
	current_health -= damage_amount
	print("%s took damage: %.2f" % [owner_entity.name, damage_amount])
	return damage_amount


func apply_damage_over_time_tick():
	var total_dot : float = 0.0
	for effect in dot_effects:
		total_dot += effect.damage_per_second * dot_effects[effect]
	total_dot *= dot_timer_tick_rate
	hurt(total_dot)
	
	
func get_health() -> float:
	return current_health


func get_health_percent() -> float :
	return current_health / max_health
	
	
func _on_modifier_added(modifier : ModifierData):
	for effect in modifier.effects:
		if dot_effects.has(effect):
			dot_effects[effect] += 1
			print("Health manager added stack to current dot effect")
		elif effect is Effect_DoT:
			dot_effects[effect] = 1
			if dot_ticker.is_stopped():
				dot_ticker.start(dot_timer_tick_rate)
				
			print("Health manager added new dot effect")


func _on_modifier_removed(modifier : ModifierData):
	for effect in modifier.effects:
		if dot_effects.has(effect):
			dot_effects[effect] -= 1
			if dot_effects[effect] == 0:
				dot_effects.erase(effect)
				if dot_effects.is_empty():
					dot_ticker.stop()


func _on_dot_timer_timeout() -> void:
	apply_damage_over_time_tick()
