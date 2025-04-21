class_name ProjectileBehaviourPenetrate
extends ProjectileListenerBehaviour

func _ready_behaviour() -> void:
	for behaviour in projectile_origin.behaviours:
		if behaviour is ProjectileBehaviourRaycast:
			behaviour.ray_collision_checks += projectile_behaviour_data.penetrate_additional_penetrations
	return
	
func _process_behaviour(delta: float) -> void:
	return
	
func _physics_process_behaviour(delta: float) -> void:
	return

func _end_behaviour() -> void:
	behaviour_ended.emit()
