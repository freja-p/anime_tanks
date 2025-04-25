class_name Ability
extends Resource

@export var ability_name : String = "Ability"
@export var icon : Image
@export var activation_sfx : AudioStream
@export var cooldown_resource : CooldownResource

@export_category("Activation")
@export var activation_type : AbilityExecutor.ActivationType
@export_subgroup("Single")
@export_subgroup("Auto")
@export_subgroup("Burst")
@export var duration : float = 1.0
@export var time_between_burst : float = 1.0
@export_subgroup("Toggle")
@export var max_duration : float = 1.0


@export_category("Behaviours")
@export var create_projectile : bool = false
@export_subgroup("Projectile", "proj_")
@export var proj_behaviours : Array[ProjectileBehaviourData]
@export var proj_lifeTime : float = 60.0

@export_subgroup("RigidBody", "projbody_")
@export var projbody_initial_velocity : float = 100.0

@export_category("Buff Application")
@export var apply_buffs : bool = false
@export_subgroup("Modifiers", "buff_")
@export var buff_apply_on_activate : Array[BuffData]
@export var buff_remove_on_activate : Array[BuffData]
@export var buff_apply_on_deactivate : Array[BuffData]
@export var buff_remove_on_deactivate : Array[BuffData]


@export_category("AI")
@export var selection_weight : int = 10


func build(shooter_entity : Entity_Vehicle, hardpoint : Enums.Hardpoint) -> ProjectileBase:
	var new_projectile = ProjectileBase.new()
	new_projectile.shooter = shooter_entity
	new_projectile.stat_calculator = shooter_entity.stat_calculator
	new_projectile.hardpoint = hardpoint
	new_projectile.ability_data = self
	
	for b in proj_behaviours:
		new_projectile.add_behaviour(b)
		
	return new_projectile
