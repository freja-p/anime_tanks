class_name ProjectileBehaviourRaycast
extends ProjectileBehaviour

signal projectile_collided(collision_point : Vector3, collision_normal : Vector3)

const COLLISION_MASK_TERRAIN = 1
const COLLISION_MASK_HITBOX = 8

@export var vfx : VFXData

var checkCount : int = 3
var ray_collision_checks : int = 1
var ray_target : Vector3

@onready var ray : RayCast3D = $ForwardRay

func _ready_behaviour():
	ray_target = global_position + global_basis.z * 100
	
func _physics_process_behaviour(delta):
	var query_params : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		global_position, 
		ray_target)
	query_params.collide_with_areas = true
	query_params.collision_mask = COLLISION_MASK_TERRAIN + COLLISION_MASK_HITBOX
	
	var worldspace : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	var rid_exclusions : Array[RID]
	var i = 0
	
	while i < ray_collision_checks:
		query_params.exclude = rid_exclusions
		var result : Dictionary = worldspace.intersect_ray(query_params)
		
		if result.is_empty():
			var vfx_pos = global_position + ray_target
			create_vfx(vfx_pos)
			break
		
		if result.collider is Hitbox:
			print("Hit: {0}".format([result.collider.get_entity()]))
			
			if result.collider.ownerEntity == projectile_origin.shooter:
				i = i - 1
			else:
				result.collider.hit(
					projectile_origin.damage, 
					projectile_origin.shooter, 
					projectile_origin.modifier_payload
					)
				create_vfx(result.position)
				projectile_collided.emit(result.position, result.normal)
			rid_exclusions.append(result.rid)
			
		else:
			create_vfx(result.position)
			projectile_collided.emit(result.position, result.normal)
			
		i = i + 1

	behaviour_ended.emit(self)

func create_vfx(world_pos : Vector3):
	var new_vfx : VFX = vfx.build()
	get_tree().root.add_child(new_vfx)
	new_vfx.global_position = world_pos
	new_vfx.play()
	
