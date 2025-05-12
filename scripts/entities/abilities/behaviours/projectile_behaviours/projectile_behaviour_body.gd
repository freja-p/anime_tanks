class_name ProjectileBehaviourBody
extends ProjectileBehaviour

const COLLISION_MASK_TERRAIN = 1
const COLLISION_MASK_HITBOX = 8

var last_frame_position : Vector3

@onready var local_body : RigidBody3D = $Body
@onready var worldspace : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state


func _ready_behaviour() -> void:
	get_tree().create_timer(projectile_behaviour_data.body_lifetime_sec).timeout.connect(_end_behaviour)
	local_body.body_shape_entered.connect(_on_body_shape_entered)
	last_frame_position = local_body.global_position
	local_body.apply_impulse(global_basis.z * projectile_behaviour_data.body_initial_velocity * local_body.mass)


func _physics_process_behaviour(_delta):
	var query_params : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		local_body.global_position,
		local_body.global_position + local_body.linear_velocity * _delta
		)
		
	query_params.collide_with_areas = true
	query_params.collision_mask = COLLISION_MASK_TERRAIN + COLLISION_MASK_HITBOX
	query_params.exclude = projectile_origin.shooter.get_hitboxes().map(
		func (x): return x.get_rid()
	)
	
	var result : Dictionary = worldspace.intersect_ray(query_params)
	
	if not result.is_empty():
		create_vfx(result.position)
		if result.collider is Hitbox:
#			if not collider.get_entity() == shooter:
			projectile_origin.projectile_collided.emit(result, false, self)
			_end_behaviour()
		else:
			_end_behaviour()
			
	last_frame_position = local_body.global_position
	
	
func create_vfx(world_pos : Vector3):
	var new_vfx : VFX = projectile_behaviour_data.vfx.build()
	get_tree().root.add_child(new_vfx)
	new_vfx.play(world_pos, global_basis)

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	create_vfx(local_body.global_position)
	if body is not Hitbox:
		_end_behaviour()
		return
		
	var result : Dictionary
	result.collider = body
	result.collider_id = body_shape_index
	result.position = local_body.global_position
	result.rid = body_rid
	projectile_origin.projectile_collided.emit(result, true, self)
	_end_behaviour()
