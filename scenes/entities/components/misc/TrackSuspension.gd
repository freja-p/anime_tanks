extends Node3D
class_name TrackSuspension

@export var wheel_radius: float = 0.35
@export var spring_stiffness_curve: Curve
@export var wheel : WheelMeshScript

@onready var ray: RayCast3D = get_node("GroundRay")

var spring_distance_max_in: float
var spring_distance_max_out: float
var spring_constant: float
var spring_damping: float
var force: Vector3
var offset: Vector3
var spring_distance: float
var spring_distance_now: float
var spring_rest_position: float
var wheel_position: Vector3
var spring_velocity: float

var arg : float

func init_suspension(rest_force: float, arg_spring_distance_max_in: float, arg_spring_distance_max_out: float, arg_spring_constant: float, arg_spring_damping: float):
	spring_distance_max_in = arg_spring_distance_max_in
	spring_distance_max_out = arg_spring_distance_max_out
	spring_constant = arg_spring_constant
	spring_damping = arg_spring_damping
	ray.target_position = Vector3(0, -(wheel_radius + spring_distance_max_out), 0)
	spring_distance = 0
	spring_rest_position = rest_force / spring_constant
#	print("%f | %f | %f" % [rest_force, spring_constant, spring_rest_position])

func add_spring_force(delta: float, vehicle_body: RigidBody3D, vehicle_rotation: Quaternion) -> bool:
	var has_contact: bool = ray.is_colliding()
	var stiffness_factor: float = 1
	if has_contact:
		var contact_point: Vector3 = ray.get_collision_point()
		var contact_point_vehicle: Vector3 = vehicle_body.to_local(contact_point)
		$MeshInstance3D.position = Vector3(0.0, contact_point_vehicle.y, 0.0)
		spring_distance_now = contact_point_vehicle.y + wheel_radius
		spring_velocity = (spring_distance_now - spring_distance) / delta
		spring_distance = spring_distance_now
		if spring_distance > 0:
			arg = spring_distance / spring_distance_max_in
			stiffness_factor = spring_stiffness_curve.sample(arg)
		var spring_force = stiffness_factor * spring_constant * (spring_distance + spring_rest_position) # Hooke's Law
		var damping_force: float = spring_damping * spring_velocity
		force = Vector3(0, spring_force + damping_force, 0)
		offset = vehicle_rotation * contact_point_vehicle
		vehicle_body.apply_force(force, offset)
		wheel_position = Vector3(0, spring_distance, 0)
	else:
		spring_distance = 0
		wheel_position = Vector3(0, -spring_distance_max_out, 0)
	wheel.update_wheel_pos(wheel_position)
	return has_contact

func get_arg() -> float:
	return arg
