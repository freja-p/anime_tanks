class_name ProjectileBehaviourData
extends Resource

enum BehaviourLogic {
	RAYCAST,
	RIGIDBODY,
	HOMING_RIGIDBODY,
	RICOCHET,
}

const PROJECTILE_BODY = preload("res://scenes/entities/vehicle_parts/abilities/autogun/autogun_projectiles/projectile_body/projectile_body.tscn")
const PROJECTILE_BEHAVIOUR_RAYCAST = preload("res://scenes/entities/vehicle_parts/abilities/autogun/autogun_projectiles/projectile_raycast/projectile_behaviour_raycast.tscn")
const PROJECTILE_MICROROCKET = preload("res://scenes/entities/vehicle_parts/abilities/micro_rockets/projectile_microrocket.tscn")

@export var behaviour_logic : BehaviourLogic
@export var vfx : VFXData

@export_subgroup("Damage", "damage")
@export var damage_damage : float = 10.0

@export_subgroup("Ricochet", "ricochet")
@export var ricochet_count : int = 1
@export var ricochet_search_radius : float = 10.0
@export var ricochet_damage_multiplier : float = 0.8

var is_listener : bool

func build() -> ProjectileBehaviour:
	var behaviour : ProjectileBehaviour
	match behaviour_logic:
		BehaviourLogic.RAYCAST:
			behaviour = PROJECTILE_BEHAVIOUR_RAYCAST.instantiate()
			is_listener = false
		BehaviourLogic.RICOCHET:
			behaviour = ProjectileBehaviourRicochet.new()
			is_listener = true
			
	behaviour.projectile_behaviour_data = self
	return behaviour
