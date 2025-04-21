class_name Projectile_Body
extends Projectile

@onready var projectileBody : RigidBody3D = $Rigidbody3D
@onready var life_timer = $LifeTimer
@onready var penetration_ray_checker = $Rigidbody3D/PenetrationRayChecker
@onready var animation_player = $AnimationPlayer
@onready var explosion = $Explosion

var initial_velocity : float = 0.0
var lastFramePosition : Vector3


func start() -> void:
	lastFramePosition = global_position
	
	life_timer.start(ability_resource.lifeTime)
	projectileBody.apply_impulse(basis.z * ability_resource.initial_velocity * projectileBody.mass)

func _physics_process(_delta):
	if dying:
		return
	
	if penetration_ray_checker.is_colliding():
		var collider = penetration_ray_checker.get_collider()
		if collider is Hitbox:
#			if not collider.get_entity() == shooter:
			hitbox_intersected(collider)
			_start_dying(penetration_ray_checker.get_collision_point())
		else:
			_start_dying(penetration_ray_checker.get_collision_point())

	penetration_ray_checker.global_position = lastFramePosition
	penetration_ray_checker.target_position = projectileBody.global_position - lastFramePosition
	lastFramePosition = projectileBody.global_position


func _start_dying(deathPosition : Vector3):
	if dying:
		return
		
	projectileBody.visible = false 
	explosion.global_position = deathPosition
	animation_player.play("explode")
	_die()

func _on_rigidbody_3d_body_entered(body):
	print("hit")
	if body is Hitbox:
		hitbox_intersected(body)
		_start_dying(projectileBody.global_position)
	else:
		_start_dying(projectileBody.global_position)

func _on_life_timer_timeout():
	_start_dying(projectileBody.global_position)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "explode":
		queue_free()
