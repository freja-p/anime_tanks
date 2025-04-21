class_name ProjectileBehaviourBody
extends ProjectileBehaviour

const COLLISION_MASK_TERRAIN = 1
const COLLISION_MASK_HITBOX = 8

var initial_velocity : float = 0.0
var last_frame_position : Vector3

@onready var body : RigidBody3D = $Body
@onready var worldspace : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
@onready var ray_cast_3d: RayCast3D = $RayCast3D


func _ready_behaviour() -> void:
	get_tree().create_timer(projectile_behaviour_data.body_lifetime_sec).timeout.connect(_end_behaviour)
	last_frame_position = body.global_position
	body.apply_impulse(global_basis.z * projectile_behaviour_data.body_initial_velocity * body.mass)
	ray_cast_3d.reparent(get_tree().root)


func _physics_process_behaviour(_delta):
	var query_params : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		body.global_position,
		body.global_position + body.linear_velocity * _delta
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
			projectile_origin.projectile_collided.emit(result, self)
			_end_behaviour()
		else:
			_end_behaviour()
			
	last_frame_position = body.global_position


func _on_rigidbody_3d_body_entered(body):
	if body is Hitbox:
		projectile_origin.projectile_collided.emit(self)
		_end_behaviour()
	else:
		_end_behaviour()
		
func create_vfx(world_pos : Vector3):
	var new_vfx : VFX = projectile_behaviour_data.vfx.build()
	get_tree().root.add_child(new_vfx)
	new_vfx.global_position = world_pos
	new_vfx.play()
