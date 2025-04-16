class_name ProjectileBehaviourData
extends Resource

enum BehaviourLogic {
	RAYCAST,
	RIGIDBODY,
	HOMING_RIGIDBODY,
	RICOCHET,
}

@export var behaviour_logic : BehaviourLogic

@export_subgroup("Ricochet", "ricochet")
@export var ricochet_count : int = 1
@export var ricochet_search_radius : float = 10.0
@export var ricochet_damage_multiplier : float = 0.8

const PROJECTILE_BODY = preload("res://scenes/entities/vehicle_parts/abilities/autogun/autogun_projectiles/projectile_body/projectile_body.tscn")
const PROJECTILE_BEHAVIOUR_RAYCAST = preload("res://scenes/entities/vehicle_parts/abilities/autogun/autogun_projectiles/projectile_raycast/projectile_behaviour_raycast.tscn")
const PROJECTILE_MICROROCKET = preload("res://scenes/entities/vehicle_parts/abilities/micro_rockets/projectile_microrocket.tscn")

func build() -> ProjectileBehaviour:
	var behaviour : ProjectileBehaviour	
	match behaviour_logic:
		BehaviourLogic.RAYCAST:
			behaviour = PROJECTILE_BEHAVIOUR_RAYCAST.instantiate()
		BehaviourLogic.RICOCHET:
			behaviour = ProjectileBehaviourRicochet.new()
			
	behaviour.projectile_behaviour_data = self
	return behaviour
