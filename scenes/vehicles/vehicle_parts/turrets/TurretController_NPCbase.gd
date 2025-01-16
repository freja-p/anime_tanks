class_name TurretController_NPCbase
extends TurretController_base

@export_category("Prefire Warn")
@export var prefireDelay : float = 1.0

@onready var prefireParticles : GPUParticles3D = $Base_Turret/Gun_Barrel/ProjectileSpawnPoint/PrefireParticles
@onready var prefireTimer : Timer = $PrefireTimer

func shoot() -> void:
	prefireTimer.start(prefireDelay)
	prefireParticles.emitting = true
	pass

#func _on_prefire_timer_timeout():
#	prefireParticles.emitting = false
#	_shoot_projectile()
