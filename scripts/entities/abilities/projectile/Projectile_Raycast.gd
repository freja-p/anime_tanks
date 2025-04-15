class_name Projectile_Raycast
extends Projectile

@export var vfx : VFXData

var collided : bool = false
var checkCount : int = 3

@onready var ray : RayCast3D = $ForwardRay

func _physics_process(delta):
	if checkCount < 1 or dying:
		return
	
	var collider = ray.get_collider()
	if collider:
		#explosion_vfx.global_position = ray.get_collision_point()
		if collider is Hitbox:
			if collider.ownerEntity != shooter:
				hitbox_intersected(collider)
			_die()

	checkCount -= 1
	if checkCount < 1 and not dying:
		_die()

func start():
	var targetVector = Vector3.ZERO
	targetVector.z = 100
	ray.target_position = targetVector
	#explosion_vfx.position = targetVector
	#explosion_vfx.end_animation_callback = queue_free

func _die():
	dying = true
	#explosion_vfx.play()
