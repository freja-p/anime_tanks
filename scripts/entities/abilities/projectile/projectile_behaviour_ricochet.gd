extends ProjectileBehaviour

func _ready_behaviour() -> void:
	return

func reproject_projectile(projectile : ProjectileBehaviour) -> void:
	projectile.duplicate()
	return
