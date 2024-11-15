class_name AttackState
extends AiState

enum AttackStage {
	AIM,
	LOCK,
	FIRE,
	COOLDOWN,
}

@export_category("State Transitions")
@export var idle_state : AiState
@export var flee_state : FleeState

@export_category("State Variables")
@export var turret : TurretComponent
@export var lock_on_time : float = 1
@export var lock_turn_rate : float = 1

var target_entity : Entity
var attack_stage : AttackStage
var turret_controller : TurretController:
	get:
		return turret.controller

var lock_wait_timedout : bool

var lock_on_timer : Timer
var active_ability : AbilityExecutor

func _ready() -> void:
	lock_on_timer = Timer.new()
	lock_on_timer.one_shot = true
	lock_on_timer.autostart = false
	lock_on_timer.timeout.connect(_lock_wait_timeout)
	add_child(lock_on_timer)

func _enter_state() -> void:
	target_entity = threat_analyzer.get_highestThreat()
	attack_stage = AttackStage.AIM
	turret.aim_at(target_entity.global_position)
	active_ability = null

func _on_tick(_delta : float):
	if entity.health_manager.get_health_percent() < flee_state.flee_state_threshold:
		change_state(flee_state)
		return
	
	match attack_stage:
		AttackStage.AIM:
			process_aim()
		AttackStage.LOCK:
			process_lock()
		AttackStage.FIRE:
			process_fire()
		AttackStage.COOLDOWN:
			process_cooldown()

func process_aim() -> void:
	turret_controller.aim_at(target_entity.global_position)
	if turret_controller.targetting_state == TurretController.TargettingState.REACHED:
		if turret_controller.aiming_state == TurretController.AimState.ENTITY:
			var targetting_entity : Entity = turret_controller.lookingAtEntity
			if targetting_entity == target_entity:
				advance_attack_stage()
				

func process_lock() -> void:
	if lock_on_timer.time_left > 0.5 and turret_controller.aiming_state == TurretController.AimState.NOTHING:
		reset_attack_stage()
		return
	
	var targetting_entity : Entity = turret_controller.lookingAtEntity
	if lock_on_timer.time_left > 0.5 and targetting_entity != target_entity:
		reset_attack_stage()
	
	turret_controller.aim_at(target_entity.global_position, lock_turn_rate)
	
	if lock_wait_timedout:
		advance_attack_stage()
	
	
func process_fire() -> void:
	turret_controller.aim_at(target_entity.global_position)
	pass
	
	
func process_cooldown() -> void:
	pass
	
	
func advance_attack_stage() -> void:
	match attack_stage:
		AttackStage.AIM:
			attack_stage = AttackStage.LOCK
			lock_wait_timedout = false
			lock_on_timer.start(lock_on_time)
			
		AttackStage.LOCK:
			attack_stage = AttackStage.FIRE
			attack_stage = _activate_ability(entity.equipmentLoadout.get_equipment(Enums.Hardpoint.PRIMARY))

		AttackStage.FIRE:
			attack_stage = AttackStage.COOLDOWN
		
		AttackStage.COOLDOWN:
			attack_stage = AttackStage.AIM
	
	print("Advance to stage: %s" % AttackStage.find_key(attack_stage) )


func reset_attack_stage() -> void:
	lock_on_timer.stop()
	attack_stage = AttackStage.AIM
	print("Reset attack stage")


func _lock_wait_timeout() -> void: 
	lock_wait_timedout = true


func _activate_ability(ability_executor : AbilityExecutor) -> AttackStage:
	match ability_executor.ability_resource.activation_type:
		AbilityExecutor.ActivationType.SINGLE:
			ability_executor.activate()
			return AttackStage.COOLDOWN
			
		AbilityExecutor.ActivationType.AUTO:
			printerr("AI Cannot use AUTO type abilities")
			return AttackStage.AIM
			
		AbilityExecutor.ActivationType.BURST:
			ability_executor.activate()
			active_ability = ability_executor
			return AttackStage.FIRE

		AbilityExecutor.ActivationType.TOGGLE:
			ability_executor.activate()
			return AttackStage.COOLDOWN
			
	return AttackStage.FIRE
