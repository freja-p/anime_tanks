extends RayCast3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_world_collision():
	if is_colliding():
		return get_collision_point()
	else:
		var local_pos = position
		local_pos.z += target_position.z
		return to_global(local_pos)
		
