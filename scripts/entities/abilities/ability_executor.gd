class_name AbilityExecutor
extends Node

# TODO: Refactor this? Should Cooldown be integrated into this? 
# How to get data into this script if so, and manage Timers at the same time?
signal ability_ready(ability : AbilityExecutor)
signal ability_activated(ability : AbilityExecutor)
signal ability_cooldown_started(ability : AbilityExecutor)

enum ActivationType {
	SINGLE,
	AUTO,
	BURST,
	TOGGLE
}

enum AbilityState {
	READY, 
	ACTIVE,
	COOLDOWN,
	RELOAD
	}
	
var ability_resource : Ability
var cooldown_resource : CooldownResource
var cooldown : CooldownInterface
var ownerEntity : Entity
var hardpoint : Enums.Hardpoint
var hardpointNode : Node3D
var stat_calculator : StatCalculator

var modifiers : Array[BuffData] = []
var target : Vector3 = Vector3.ZERO
var readyToUse : bool = true
var autofiring : bool = false

var isReady : bool:
	get: 
		return cooldown.ready_to_activate()
	set(_val): 
		return

var isActive : bool:
	get: 
		return _currentState == AbilityState.ACTIVE
	set(_val): 
		return

var _currentState : AbilityState

@onready var sfxPlayer = %ActivateSFXPlayer as AudioStreamPlayer3D
@onready var activeDurationTimer = %ActiveDurationTimer as Timer


func _ready():
	_currentState = AbilityState.READY

# TODO: Make this like a builder pattern? Maybe make Ability.build() return an AbilityExecutor instead?
func construct(ability : Ability, arg_hardpoint : Enums.Hardpoint, arg_ownerEntity : Entity, stat_calculator : StatCalculator):
	ownerEntity = arg_ownerEntity
	hardpoint = arg_hardpoint
	hardpointNode = arg_ownerEntity.get_hardpoint(arg_hardpoint)
	ability_resource = ability
	
	cooldown = ability.cooldown_resource.create_instance(stat_calculator, ability)
	add_child(cooldown)
	cooldown.cooldown_ended.connect(_on_ability_cooldown_timeout)
	
	# I don't like this pattern but I just want this to work
	if cooldown.has_signal("reload_started"):
		cooldown.reload_started.connect(_on_reloaded)


func activate(toggle_on : bool = true) -> bool:
	if not toggle_on:
		autofiring = false
		return false
		
	if not isReady:
		print("not ready")
		return false
	
	match ability_resource.activation_type:
		ActivationType.SINGLE:
			if not toggle_on:
				return false
			_enter_cooldown()
			
		ActivationType.AUTO:
			if toggle_on:
				autofiring = true
				_enter_cooldown()	
			else:
				return false
				
		ActivationType.BURST:
			if not toggle_on:
				return false
			cooldown.start_cooldown()
			_enter_active()
			
		ActivationType.TOGGLE:
			if isActive:
				_enter_cooldown()
				return false
			else:
				_enter_active()
				
	_execute_logic()
	return true


func _execute_logic():
	AbilityLogicManager.execute_logic(
			ability_resource, 
			hardpointNode,
			ownerEntity, 
			stat_calculator.get_hardpoint_stat(
					ability_resource.base_damage, 
					hardpoint, 
					Enums.HardpointStat.DAMAGE),
			stat_calculator.get_hardpoint_stat(
				ability_resource.secondary_damage, 
				hardpoint, 
				Enums.HardpointStat.SECONDARY_DAMAGE),
			modifiers)
					
	if sfxPlayer.has_stream_playback(): sfxPlayer.play()
	ability_activated.emit(self)
	return true


func get_weight() -> int:
	return ability_resource.selection_weight


func set_modifiers(arg_modifiers : Array[BuffData]) -> void:
	modifiers = arg_modifiers


func _enter_active() -> void:
	_currentState = AbilityState.ACTIVE
	activeDurationTimer.start(ability_resource.duration)


func _enter_cooldown() -> void:
	cooldown.start_cooldown()
	_currentState = AbilityState.COOLDOWN
	ability_cooldown_started.emit(self)


func _enter_ready() -> void:
	_currentState = AbilityState.READY
	ability_ready.emit(self)
	
	
func _on_ability_cooldown_timeout():
	match ability_resource.activation_type:
		ActivationType.SINGLE, ActivationType.TOGGLE:
			_enter_ready()
			
		ActivationType.BURST:
			if activeDurationTimer.is_stopped():
				_enter_ready()
			else:
				_execute_logic()
				cooldown.start_cooldown()
				
		ActivationType.AUTO:
			if autofiring:
				_execute_logic()
				cooldown.start_cooldown()
			else:
				_enter_ready()
			
			
func _on_active_duration_timer_timeout():
	_enter_cooldown()

func _on_reloaded():
	activeDurationTimer.stop()
