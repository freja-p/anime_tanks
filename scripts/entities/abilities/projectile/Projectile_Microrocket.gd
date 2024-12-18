class_name Projectile_MicroRocket
extends Projectile

@export var speed : float = 35
@export var base_damage : float = 10
var isTurning : bool = false
var target : Vector3
var timeToRound : int = 30

@onready var hit_ray: RayCast3D = $HitRay

func _process(delta):
	if dying:
		return
	if isTurning:
		if position.distance_to(target) < 5.0:
			isTurning = false

		basis = basis.slerp(Basis.looking_at(global_position.direction_to(target), Vector3.UP, true), 0.05)
	var forward = Vector3.MODEL_FRONT * speed * delta
	translate_object_local(forward)
	hit_ray.target_position = forward
	
func _physics_process(delta: float) -> void:
	if hit_ray.is_colliding():
		var collider = hit_ray.get_collider()
		if collider is Hitbox:
			if collider.ownerEntity == shooter:
				return
			collider.hit(damage, shooter, modifier_payload)
		global_position = hit_ray.get_collision_point()
	
		dying = true
		$Explosion.explode()

func initialise(worldPos : Vector3, rot : Basis) -> void:
	global_transform.origin = worldPos
	global_transform.basis = Basis(rot.x, -rot.z, rot.y)
	target = shooter.get_target_point()
	$TurnDelay.start(randf_range(0.1, 0.5))

func calculate_hit(collider : Node3D):
	if collider is Hitbox:
		if collider.ownerEntity == shooter:
			return
		collider.hit(damage, shooter, modifier_payload)
	
	dying = true
	$Explosion.explode()
		

func _on_turn_delay_timeout():
	isTurning = true
	pass

func _on_area_entered(area : Area3D):
	calculate_hit(area)

func _on_body_entered(body):
	calculate_hit(body)
