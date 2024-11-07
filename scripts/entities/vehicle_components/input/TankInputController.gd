extends VehicleBody3D

@export var left : Array[VehicleWheel3D]
@export var right : Array[VehicleWheel3D]

const ENGINE_FORCE = 5000

func _unhandled_input(event: InputEvent) -> void:
	var steer_target = Input.get_axis("move_left", "move_right")
	if not is_zero_approx(steer_target): 
		print(steer_target)
	for w in left:
		w.engine_force = ENGINE_FORCE  * steer_target
	for w in right:
		w.engine_force = -ENGINE_FORCE  * steer_target
	
	#var forward = Input.get_axis("move_backward", "move_forward")
	#for w in left:
		#w.engine_force = forward * ENGINE_FORCE
	#for w in right:
		#w.engine_force = forward * ENGINE_FORCE
