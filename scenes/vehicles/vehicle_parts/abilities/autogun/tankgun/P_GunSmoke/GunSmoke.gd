class_name GunSmokeParticle
extends GPUParticles3D

@onready var particleTimer : Timer = $ParticleTimeout

func initialise(worldPos : Vector3, worldRot : Vector3):
	global_position = worldPos
	global_rotation = worldRot
	particleTimer.wait_time = lifetime
	particleTimer.start()

func _on_particle_timeout_timeout():
	queue_free()
