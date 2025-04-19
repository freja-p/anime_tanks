class_name Ability
extends Resource

@export_category("Parameters")
@export var ability_name : String = "Ability"
@export var icon : Image
@export var activation_sfx : AudioStream
@export var base_damage : float = 10.0
@export var secondary_damage : float = 5.0
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

@export_category("Projectile")
@export var projectile_scene : PackedScene
@export var behaviours : Array[ProjectileBehaviourData]
@export var lifeTime : float = 2.0
@export_subgroup("RigidBody")
@export var initial_velocity : float = 100.0

@export_category("Modifiers")
@export var modifiers_on_activation : Array[ModifierData]
@export var remove_modifiers_on_deactivation : bool = true

@export_category("AI")
@export var selection_weight : int = 10

const PROJECTILE = preload("res://scenes/entities/vehicle_parts/abilities/projectile.tscn")

# TODO: When should this be called?
func build(shooter_entity : Entity_Vehicle, hardpoint : Enums.Hardpoint) -> ProjectileBase:
	var new_projectile = ProjectileBase.new()
	new_projectile.shooter = shooter_entity
	new_projectile.stat_calculator = shooter_entity.stat_calculator
	new_projectile.hardpoint = hardpoint
	new_projectile.ability_data = self
	
	for b in behaviours:
		new_projectile.add_behaviour(b)
		
	return new_projectile
