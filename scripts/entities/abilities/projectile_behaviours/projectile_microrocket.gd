class_name Projectile_MicroRocket
extends Projectile

@export var speed : float = 35
var isTurning : bool = false
var target : Vector3
var timeToRound : int = 30

@onready var hit_ray: RayCast3D = $HitRay
@onready var explosion_vfx: ExplosionVFX = $ExplosionVFX

func _ready() -> void:
	explosion_vfx.entities_hit.connect(_on_explosion_entities_hit)

func _physics_process(delta: float) -> void:
	if dying:
		return
	if isTurning:
		if position.distance_to(target) < 5.0:
			isTurning = false

		basis = basis.slerp(Basis.looking_at(global_position.direction_to(target), Vector3.UP, true), 0.05)
	
	var forward = Vector3.MODEL_FRONT * speed * delta
	translate_object_local(forward)
	hit_ray.target_position = forward
	
	if hit_ray.is_colliding():
		var collider = hit_ray.get_collider()
		if collider is Hitbox:
			if collider.ownerEntity == shooter:
				return
			collider.hit(damage, shooter, modifier_payload)
		global_position = hit_ray.get_collision_point()
	
		dying = true
		explosion_vfx.explode(queue_free)

func start() -> void:
	var rot : Basis = global_basis
	global_basis = Basis(rot.x, -rot.z, rot.y)
	target = shooter.get_target_point()
	$TurnDelay.start(randf_range(0.1, 0.5))

func calculate_hit(collider : Node3D):
	if collider is Hitbox:
		if collider.ownerEntity == shooter:
			return
		collider.hit(damage, shooter, modifier_payload)
	
	dying = true
	explosion_vfx.explode(queue_free)
		

func _on_explosion_entities_hit(entity_hitboxes : Array[Hitbox]):
	for hitbox in entity_hitboxes:
		if hitbox.ownerEntity != shooter:
			hitbox.hit(secondary_damage, shooter, modifier_payload)
		

func _on_turn_delay_timeout():
	isTurning = true
	pass

func _on_area_entered(area : Area3D):
	calculate_hit(area)

func _on_body_entered(body):
	calculate_hit(body)
