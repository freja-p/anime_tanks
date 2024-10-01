extends Node

func is_grounded() -> bool:
	var grounded : bool = true
	for ray in get_children():
		if not ray.is_colliding():
			grounded = false
			return grounded
			
	return grounded
