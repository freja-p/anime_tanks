class_name ProjectileBehaviourRaycast
extends ProjectileBehaviour

var collided : bool = false
var checkCount : int = 3
var additional_ray_collision_checks : int = 1

@onready var ray : RayCast3D = $ForwardRay
@onready var explosion_vfx: ExplosionVFX = $ExplosionVFX

func _ready_behaviour():
	var targetVector = Vector3.ZERO
	targetVector.z = 100
	ray.target_position = targetVector
	explosion_vfx.position = targetVector
	
func _physics_process_behaviour(delta):
	var collider = ray.get_collider()
	if collider:
		explosion_vfx.global_position = ray.get_collision_point()
		
		if collider is Hitbox:
			if collider.ownerEntity != projectile_origin.shooter:
				collider.hit(
					projectile_origin.damage, 
					projectile_origin.shooter, 
					projectile_origin.modifier_payload
					)
		if additional_ray_collision_checks > 0:
			additional_ray_collision_checks -= 1
			ray.global_position = ray.get_collision_point()
		else:
			explosion_vfx.explode(queue_free)
			behaviour_ended.emit(self)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "explode":
		queue_free()
