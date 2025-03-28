extends CharacterBody3D

@export var rotate_speed : float = 0.5
@export var move_speed : float = 1.0
@export var suspension_curve : Curve

@onready var front: RayCast3D = $Front
@onready var back: RayCast3D = $Back

func _process(delta: float) -> void:
	var forward : float = Input.get_axis("move_backward", "move_forward")
	move_and_collide(Vector3(0, 0, forward * move_speed * delta))

func _physics_process(delta: float) -> void:
	var front_distance : float = (front.get_collision_point() - front.global_position).length() if front.is_colliding() else INF
	var back_distance : float = (back.get_collision_point() - back.global_position).length() if back.is_colliding() else INF
	
	var difference : float = front_distance - back_distance
	
	if is_zero_approx(difference):
		return
		
	if difference > 0:
		rotate_x(rotate_speed * delta)
	else:
		rotate_x(-rotate_speed * delta)
	
