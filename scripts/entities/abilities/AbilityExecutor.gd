class_name AbilityExecutor
extends Node

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
var hardPoint : Node3D
var stat_calculator : StatCalculator
var logic : Callable

var modifiers : Array[ModifierData] = []
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
@onready var burstControlTimer = %BurstControlTimer as Timer	


func _ready():
	_currentState = AbilityState.READY


func construct(ability : Ability, arg_ownerEntity : Entity, stat_calculator : StatCalculator):
	ownerEntity = arg_ownerEntity
	hardPoint = arg_ownerEntity.get_hardpoint(ability.default_hardpoint)
	ability_resource = ability
	
	cooldown = ability.cooldown_resource.create_instance(stat_calculator, ability)
	add_child(cooldown)
	cooldown.cooldown_ended.connect(_on_cooldown_timeout)


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
			hardPoint, 
			ownerEntity, 
			stat_calculator.get_hardpoint_stat(
					ability_resource.base_damage, 
					ability_resource.default_hardpoint, 
					Enums.HardpointStat.DAMAGE),
			modifiers)
					
	if sfxPlayer.has_stream_playback(): sfxPlayer.play()
	ability_activated.emit(self)
	return true


func get_weight() -> int:
	return ability_resource.selection_weight


func set_modifiers(arg_modifiers : Array[ModifierData]) -> void:
	modifiers = arg_modifiers


func _enter_active() -> void:
	_currentState = AbilityState.ACTIVE
	activeDurationTimer.start(ability_resource.duration)
	burstControlTimer.start(ability_resource.burst_delay)


func _enter_cooldown() -> void:
	cooldown.start_cooldown()
	_currentState = AbilityState.COOLDOWN
	ability_cooldown_started.emit(self)
	
	
func _on_cooldown_timeout():
	_currentState = AbilityState.READY
	match ability_resource.activation_type:
		ActivationType.SINGLE, ActivationType.BURST, ActivationType.TOGGLE:
			ability_ready.emit(self)
		ActivationType.AUTO:
			if autofiring:
				_enter_cooldown()
				_execute_logic()
			
			
func _on_active_duration_timer_timeout():
	burstControlTimer.stop()
	_enter_cooldown()


func _on_burst_control_timer_timeout():
	_execute_logic()
	burstControlTimer.start(ability_resource.burst_delay)
