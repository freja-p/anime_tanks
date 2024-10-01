class_name AbilityExecutor
extends Node

var abilityRes : Ability
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
		return _currentState == ABILITY_STATE.READY
	set(_val): 
		return

var isActive : bool:
	get: 
		return _currentState == ABILITY_STATE.ACTIVE
	set(_val): 
		return

@onready var cooldownTimer = %Cooldown as Timer
@onready var sfxPlayer = %ActivateSFXPlayer as AudioStreamPlayer3D
@onready var activeDurationTimer = %ActiveDurationTimer as Timer
@onready var burstControlTimer = %BurstControlTimer as Timer	

signal ability_ready(ability : AbilityExecutor)
signal ability_activated(ability : AbilityExecutor)

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

func initialise(ability : Ability, arg_ownerEntity : Entity, arg_hardPoint : Node3D):
	ownerEntity = arg_ownerEntity
	if arg_hardPoint:
		hardPoint = arg_hardPoint
	else:
		hardPoint = arg_ownerEntity.get_hardpoint(ability.default_hardpoint)
	abilityRes = ability

func activate(toggle_on : bool = true) -> bool:
	if autofiring and not toggle_on:
		autofiring = false
		
	if not isReady:
		return false
	
	match abilityRes.activation_type:
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
			abilityRes, 
			hardPoint, 
			ownerEntity, 
			stat_calculator.get_hardpoint_stat(
					abilityRes.base_damage, 
					abilityRes.default_hardpoint, 
					Enums.HardpointStat.DAMAGE),
			modifiers)
					
	if sfxPlayer.has_stream_playback(): sfxPlayer.play()
	ability_activated.emit(self)
	return true

func get_weight() -> int:
	return abilityRes.selection_weight

func set_modifiers(arg_modifiers : Array[ModifierData]) -> void:
	modifiers = arg_modifiers

func _enter_active() -> void:
	_currentState = ABILITY_STATE.ACTIVE
	activeDurationTimer.start(abilityRes.duration)
	burstControlTimer.start(abilityRes.burst_delay)

func _enter_cooldown() -> void:
	_currentState = ABILITY_STATE.COOLDOWN
	cooldownTimer.start(stat_calculator.get_hardpoint_stat(abilityRes.cooldown, abilityRes.default_hardpoint, Enums.HardpointStat.COOLDOWN_TIME))
	
func _on_cooldown_timeout():
	_currentState = ABILITY_STATE.READY
	match abilityRes.activation_type:
		ACTIVATION_TYPE.SINGLE, ACTIVATION_TYPE.BURST, ACTIVATION_TYPE.TOGGLE:
			ability_ready.emit(self)
		ACTIVATION_TYPE.AUTO:
			if autofiring:
				_execute_logic()
			
func _on_active_duration_timer_timeout():
	burstControlTimer.stop()
	_enter_cooldown()

func _on_burst_control_timer_timeout():
	_execute_logic()
	burstControlTimer.start(abilityRes.burst_delay)
