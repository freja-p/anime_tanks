extends Node

func player_fell(body : RigidBody3D):
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO
	body.rotation = Vector3.ZERO
	body.position = $Spawn.position

func _on_death_box_body_entered(body):
	if body.is_in_group("player"):
		player_fell(body)
	else:
		body.queue_free()
