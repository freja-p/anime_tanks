class_name ProjectileBehaviourRicochet
extends ProjectileListenerBehaviour

const COLLISION_MASK_TERRAIN = 1
const COLLISION_MASK_HITBOX = 8

var ricochets_left : int
var queried_shape : SphereShape3D = SphereShape3D.new()
var _shape_query : PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
var _rid_exclusions : Array[RID]
var _shooter_rids : Array[RID]
var _world_space : PhysicsDirectSpaceState3D

func _ready_behaviour() -> void:
	projectile_origin.projectile_collided.connect(reproject_projectile)
	_world_space = get_world_3d().direct_space_state
	
	ricochets_left = projectile_behaviour_data.ricochet_count
	
	queried_shape.radius = projectile_behaviour_data.ricochet_search_radius
	_shape_query.shape = queried_shape
	_shape_query.collide_with_areas = true
	_shape_query.collision_mask = COLLISION_MASK_HITBOX
	_shooter_rids.append_array(projectile_origin.shooter.get_hitboxes().map(
		func (x): return x.get_rid())
		)
	_shape_query.exclude = _rid_exclusions
	
	return

func reproject_projectile(collision_result : Dictionary, is_body_collision : bool, behaviour : ProjectileBehaviour) -> void:
	_shape_query.transform = Transform3D(Basis.IDENTITY, collision_result.position)
	_rid_exclusions.clear()
	_rid_exclusions.append_array(_shooter_rids)
	_rid_exclusions.append(collision_result.rid)
	_shape_query.exclude = _rid_exclusions
		
	var target_results : Array[Dictionary] = _world_space.intersect_shape(_shape_query)
	
	if target_results.is_empty() or ricochets_left == 0:
		ricochets_left = 0
		behaviour_ended.emit()
		return
	
	var nearest_target : Dictionary = target_results[0]
	var measure_distance : Callable = _get_distance.bind(collision_result.position)
	var shortest_distance : float = measure_distance.call(nearest_target.collider)
	
	for target in target_results:
		var check_dist : float = measure_distance.call(target.collider)

		if  check_dist < shortest_distance:
			nearest_target = target
			shortest_distance = check_dist
			#print("Intersected {0} : Distance {1}".format([r.collider.get_entity(), measure_distance.call(r.collider)]))
	
	print("Ricocheting to {0}".format([nearest_target.collider.get_entity()]))
	
	var new_behaviour = behaviour.projectile_behaviour_data.build()
	projectile_origin.add_child(new_behaviour)
	new_behaviour.global_position = collision_result.position
	new_behaviour.global_basis = Basis.looking_at(
		nearest_target.collider.get_entity().center.global_position - collision_result.position, 
		Vector3.UP, 
		true)
	new_behaviour.rid_exclusions.append(collision_result.rid)
	
	new_behaviour._ready_behaviour()
	projectile_origin.add_active_behaviour(new_behaviour)
	ricochets_left -= 1
	
	return

func _get_distance(hitbox : Hitbox, origin_position : Vector3):
	return origin_position.distance_squared_to(hitbox.global_position)
