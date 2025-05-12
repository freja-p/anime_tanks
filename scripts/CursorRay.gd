extends RayCast3D


func get_world_collision():
	if is_colliding():
		return get_collision_point()
	else:
		var local_pos = position
		local_pos.z += target_position.z
		return to_global(local_pos)
		
