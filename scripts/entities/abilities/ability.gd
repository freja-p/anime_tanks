class_name Ability
extends Resource

@export_category("Parameters")
@export var ability_name : String = "Ability"
@export var icon : Image
@export var activation_sfx : AudioStream
@export var default_hardpoint : Enums.Hardpoint
@export var base_damage : float = 10.0
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
@export var spawn_logic : AbilityLogic.SPAWNLOGIC
@export var projectile_scene : PackedScene
@export var lifeTime : float = 2.0
@export_subgroup("RigidBody")
@export var initial_velocity : float = 100.0

@export_category("Modifiers")
@export var modifiers_on_activation : Array[ModifierData]
@export var remove_modifiers_on_deactivation : bool = true

@export_category("AI")
@export var selection_weight : int = 10

func create_executor(arg_ownerEntity : Entity, stat_calculator : StatCalculator) -> AbilityExecutor:
	var executor : AbilityExecutor = preload("res://scenes/vehicles/Vehicle Parts/abilities/AbilityExecutor.tscn").instantiate()
	executor.construct(self, arg_ownerEntity, stat_calculator)
	executor.name = ability_name
	return executor
