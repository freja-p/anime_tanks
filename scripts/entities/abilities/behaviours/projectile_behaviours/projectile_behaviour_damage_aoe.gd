class_name ProjectileBehaviourDamageAOE
extends ProjectileListenerBehaviour

const COLLISION_MASK_HITBOX = 8

var queried_shape : SphereShape3D = SphereShape3D.new()
var _shape_query : PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
var _rid_exclusions : Array[RID]
var _shooter_rids : Array[RID]
var _world_space : PhysicsDirectSpaceState3D

func _ready_behaviour() -> void:
	projectile_origin.projectile_collided.connect(_on_projectile_collide)
	_world_space = get_world_3d().direct_space_state
	
	queried_shape.radius = projectile_behaviour_data.aoe_radius
	_shape_query.shape = queried_shape
	_shape_query.collide_with_areas = true
	_shape_query.collision_mask = COLLISION_MASK_HITBOX
	_shooter_rids.append_array(projectile_origin.shooter.get_hitboxes().map(
		func (x): return x.get_rid())
		)
	_shape_query.exclude = _rid_exclusions
	
func _on_projectile_collide(result : Dictionary, is_body_collision : bool, behaviour : ProjectileBehaviour) -> void:
	_shape_query.transform = Transform3D(Basis.IDENTITY, result.position)
	_rid_exclusions.clear()
	_rid_exclusions.append_array(_shooter_rids)
	_shape_query.exclude = _rid_exclusions
	
	var hit_results : Array[Dictionary] = _world_space.intersect_shape(_shape_query)
	
	for hit in hit_results:
		if hit.collider is Hitbox:
			hit.collider.hit(
				stat_calculator.get_hardpoint_stat(
					projectile_behaviour_data.damage_damage, 
					projectile_origin.hardpoint, 
					Enums.HardpointStat.DAMAGE),
				projectile_origin.shooter, 
				projectile_origin.modifier_payload
			)
	return
