class_name ProjectileBehaviourData
extends Resource

enum BehaviourLogic {
	DAMAGE,
	DAMAGE_AOE,
	RAYCAST,
	RIGIDBODY,
	HOMING_RIGIDBODY,
	RICOCHET,
	PENETRATE,
	REPLICATE,
	GENERATE,
	APPLY_MODIFIER,
}

const PROJECTILE_BODY = preload("res://scenes/entities/vehicle_parts/abilities/autogun/autogun_projectiles/projectile_body/projectile_body.tscn")
const PROJECTILE_BEHAVIOUR_RAYCAST = preload("res://scenes/entities/vehicle_parts/abilities/autogun/autogun_projectiles/projectile_raycast/projectile_behaviour_raycast.tscn")
const PROJECTILE_MICROROCKET = preload("res://scenes/entities/vehicle_parts/abilities/micro_rockets/projectile_microrocket.tscn")

@export var behaviour_logic : BehaviourLogic
@export var vfx : VFXData

@export_subgroup("Damage", "damage")
@export var damage_damage : float = 10.0

@export_subgroup("Damage AOE", "aoe")
@export var aoe_radius : float = 4.0

@export_subgroup("Rigidbody", "body")
@export var body_lifetime_sec : float = 60.0
@export var body_initial_velocity : float = 10
@export var body_mesh : Mesh
@export var body_collider : Shape3D

@export_subgroup("Ricochet", "ricochet")
@export var ricochet_count : int = 1
@export var ricochet_search_radius : float = 10.0
@export var ricochet_damage_multiplier : float = 0.8

@export_subgroup("Penetrate", "penetrate")
@export var penetrate_additional_penetrations : int = 1

func build() -> ProjectileBehaviour:
	var behaviour : ProjectileBehaviour
	match behaviour_logic:
		BehaviourLogic.DAMAGE:
			behaviour = ProjectileBehaviourDamage.new()
		BehaviourLogic.DAMAGE_AOE:
			behaviour = ProjectileBehaviourDamageAOE.new()
		BehaviourLogic.RAYCAST:
			behaviour = PROJECTILE_BEHAVIOUR_RAYCAST.instantiate()
		BehaviourLogic.RIGIDBODY:
			behaviour = PROJECTILE_BODY.instantiate()
		BehaviourLogic.RICOCHET:
			behaviour = ProjectileBehaviourRicochet.new()
		BehaviourLogic.PENETRATE:
			behaviour = ProjectileBehaviourPenetrate.new()

	behaviour.projectile_behaviour_data = self
	return behaviour
