class_name Projectile_Raycast
extends Projectile

@onready var ray : RayCast3D = $ForwardRay
var collided : bool = false
var checkCount : int = 3

func _physics_process(delta):
	if checkCount < 1 or dying:
		return
	
	var collider = ray.get_collider()
	if collider:
		$Explosion.global_position = ray.get_collision_point()
		if collider is Hitbox:
			if collider.ownerEntity != shooter:
				hitbox_intersected(collider)
			_die()

	checkCount -= 1
	if checkCount < 1 and not dying:
		_die()

func initialise(worldPos : Vector3, worldRot : Basis):
	global_position = worldPos
	global_transform.basis = worldRot
	var targetVector = Vector3.ZERO
	targetVector.z = 100
	ray.target_position = targetVector
	$Explosion.position = targetVector

func _die():
	dying = true
	$AnimationPlayer.play("explode")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "explode":
		queue_free()
