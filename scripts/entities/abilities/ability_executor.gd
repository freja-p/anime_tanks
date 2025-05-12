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
	
var ability : Ability
var cooldown_resource : CooldownResource
var cooldown : Cooldown

var modifiers : Array[BuffData] = []
var behaviours : Array[ProjectileBehaviourData] = []

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
var _owner_entity : Entity_Vehicle
var _hardpoint : Enums.HardpointType
var _hardpointNode : Node3D
var _stat_calculator : StatCalculator
var _active_duration_timer : Timer


func _ready():
	_currentState = AbilityState.READY
	
	_active_duration_timer = Timer.new()
	_active_duration_timer.autostart = false
	_active_duration_timer.one_shot = true
	_active_duration_timer.timeout.connect(_on_active_duration_timer_timeout)
	add_child(_active_duration_timer)
	
	cooldown = ability.cooldown_resource.build(_stat_calculator, ability)
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
	
	match ability.activation_type:
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
				
	_trigger_ability()
	return true


func _trigger_ability(trigger_on : bool = true):
	if ability.create_projectile:
		_create_projectile()
		
	if ability.apply_buffs and trigger_on:
		for buff in ability.buff_apply_on_activate:
			_owner_entity.buff_tracker.add_buff(buff)
		for buff in ability.buff_remove_on_activate:
			_owner_entity.buff_tracker.remove_buff(buff)
	
	elif ability.apply_buffs and not trigger_on:
		for buff in ability.buff_apply_on_deactivate:
			_owner_entity.buff_tracker.add_buff(buff)
		for buff in ability.buff_remove_on_deactivate:
			_owner_entity.buff_tracker.remove_buff(buff)
	
	ability_activated.emit(self)
	return true

func _create_projectile():
	var projectile : ProjectileBase = ability.build(_owner_entity, _hardpoint)
	for behaviour in behaviours:
		projectile.add_behaviour(behaviour)
		
	get_tree().get_root().add_child(projectile)
	projectile.global_position = _hardpointNode.global_position
	projectile.global_basis = _hardpointNode.global_basis
	projectile.start_behaviours()
	
	
func get_weight() -> int:
	return ability.selection_weight


func set_modifiers(arg_modifiers : Array[BuffData]) -> void:
	modifiers = arg_modifiers


func _enter_active() -> void:
	_currentState = AbilityState.ACTIVE
	_active_duration_timer.start(ability.duration)


func _enter_cooldown() -> void:
	cooldown.start_cooldown()
	_currentState = AbilityState.COOLDOWN
	ability_cooldown_started.emit(self)


func _enter_ready() -> void:
	_currentState = AbilityState.READY
	ability_ready.emit(self)
	
	
func _on_ability_cooldown_timeout():
	match ability.activation_type:
		ActivationType.SINGLE, ActivationType.TOGGLE:
			_enter_ready()
			
		ActivationType.BURST:
			if _active_duration_timer.is_stopped():
				_enter_ready()
			else:
				_trigger_ability()
				cooldown.start_cooldown()
				
		ActivationType.AUTO:
			if autofiring:
				_trigger_ability()
				cooldown.start_cooldown()
			else:
				_enter_ready()
			
			
func _on_active_duration_timer_timeout():
	_enter_cooldown()

func _on_reloaded():
	_active_duration_timer.stop()

static func build(_ability : Ability, hardpoint : Enums.HardpointType, owner_entity : Entity_Vehicle) -> AbilityExecutor:
	var new_executor : AbilityExecutor = AbilityExecutor.new()
	new_executor._owner_entity = owner_entity
	new_executor._hardpoint = hardpoint
	new_executor._hardpointNode = owner_entity.get_hardpoint(hardpoint)
	new_executor._stat_calculator = owner_entity.stat_calculator
	new_executor.ability = _ability
	new_executor.name = _ability.ability_name
	
	return new_executor
