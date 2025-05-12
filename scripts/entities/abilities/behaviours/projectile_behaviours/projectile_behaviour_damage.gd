class_name ProjectileBehaviourDamage
extends ProjectileListenerBehaviour

func _ready_behaviour() -> void:
	projectile_origin.projectile_collided.connect(_on_projectile_collide)
	
func _on_projectile_collide(result : Dictionary, is_body_collision : bool, behaviour : ProjectileBehaviour) -> void:
	if result.collider is Hitbox:
		result.collider.hit(
			stat_calculator.get_hardpoint_stat(
				projectile_behaviour_data.damage_damage, 
				projectile_origin.hardpoint, 
				Enums.HardpointStat.DAMAGE),
			projectile_origin.shooter, 
			projectile_origin.modifier_payload
		)
	return
