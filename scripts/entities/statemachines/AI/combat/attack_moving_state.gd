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
@export var test : float = 1
@export var turret : TurretComponent

var target_entity : Entity
var attack_stage : AttackStage
var turret_controller : TurretController:
	get:
		return turret.controller
		
func _enter_state() -> void:
	target_entity = threat_analyzer.get_highestThreat()
	attack_stage = AttackStage.AIM
	turret.aim_at(target_entity.global_position)

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
		match turret_controller.aiming_state:
			TurretController.TargettingState.TURNING:
				turret_controller.aim_at(target_entity.global_position)
			TurretController.TargettingState.REACHED:
				if turret_controller.aiming_state == TurretController.AimState.ENTITY:
					var targetting_entity : Entity = turret_controller.lookingAtEntity
					if targetting_entity == target_entity:
						advance_attack_stage()


func process_lock() -> void:
	pass
	
func process_fire() -> void:
	pass
	
func process_cooldown() -> void:
	pass
	
func advance_attack_stage() -> void:
	match attack_stage:
		AttackStage.AIM:
			attack_stage = AttackStage.LOCK
		AttackStage.LOCK:
			attack_stage = AttackStage.FIRE
		AttackStage.FIRE:
			attack_stage = AttackStage.COOLDOWN
		AttackStage.COOLDOWN:
			attack_stage = AttackStage.AIM

func reset_attack_stage() -> void:
	attack_stage = AttackStage.AIM
			
