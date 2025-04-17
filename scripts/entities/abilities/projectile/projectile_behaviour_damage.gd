class_name ProjectileBehaviourDamage
extends ProjectileBehaviour

func _ready_behaviour() -> void:
	projectile_origin.projectile_collided.connect(_on_projectile_collide)
	
func _on_projectile_collide(result : Dictionary, behaviour : ProjectileBehaviour) -> void:
	result.collider.hit(
		stat_calculator.get_hardpoint_stat(
			projectile_behaviour_data.damage_damage, 
			projectile_origin.hardpoint, 
			Enums.HardpointStat.DAMAGE),
		projectile_origin.shooter, 
		projectile_origin.modifier_payload
	)
	return
