class_name AbilityExecutor
extends Node

var ability_resource : Ability
var cooldown_resource : CooldownResource
var cooldown : Cooldown
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
		return _currentState == ABILITY_STATE.ACTIVE
	set(_val): 
		return

@onready var sfxPlayer = %ActivateSFXPlayer as AudioStreamPlayer3D
@onready var activeDurationTimer = %ActiveDurationTimer as Timer
@onready var burstControlTimer = %BurstControlTimer as Timer	

signal ability_ready(ability : AbilityExecutor)
signal ability_activated(ability : AbilityExecutor)
signal ability_cooldown_started(ability : AbilityExecutor)

enum ACTIVATION_TYPE {
	SINGLE,
	AUTO,
	BURST,
	TOGGLE
}

enum ABILITY_STATE {
	READY, 
	ACTIVE,
	COOLDOWN
	}

var _currentState : ABILITY_STATE

func _ready():
	_currentState = ABILITY_STATE.READY

func initialise(ability : Ability, arg_ownerEntity : Entity, stat_calculator : StatCalculator):
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
		ACTIVATION_TYPE.SINGLE:
			if not toggle_on:
				return false
			_enter_cooldown()
			
		ACTIVATION_TYPE.AUTO:
			if toggle_on:
				autofiring = true
				_enter_cooldown()	
			else:
				return false
				
		ACTIVATION_TYPE.BURST:
			if not toggle_on:
				return false
			_enter_active()
			
		ACTIVATION_TYPE.TOGGLE:
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
	_currentState = ABILITY_STATE.ACTIVE
	activeDurationTimer.start(ability_resource.duration)
	burstControlTimer.start(ability_resource.burst_delay)

func _enter_cooldown() -> void:
	cooldown.start_cooldown()
	_currentState = ABILITY_STATE.COOLDOWN
	ability_cooldown_started.emit(self)
	
func _on_cooldown_timeout():
	_currentState = ABILITY_STATE.READY
	match ability_resource.activation_type:
		ACTIVATION_TYPE.SINGLE, ACTIVATION_TYPE.BURST, ACTIVATION_TYPE.TOGGLE:
			ability_ready.emit(self)
		ACTIVATION_TYPE.AUTO:
			if autofiring:
				_enter_cooldown()
				_execute_logic()
			
func _on_active_duration_timer_timeout():
	burstControlTimer.stop()
	_enter_cooldown()

func _on_burst_control_timer_timeout():
	_execute_logic()
	burstControlTimer.start(ability_resource.burst_delay)
