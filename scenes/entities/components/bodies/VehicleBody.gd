class_name VehicleBody
extends Node3D

@onready var rightTracks = $tank_wheels_R as WheelSystem
@onready var leftTracks = $tank_wheels_L as WheelSystem

var entityBody : RigidBody3D
var centerVector : Vector3

func initialise(body : RigidBody3D, vehicleParams : VehicleParameters, materialOverride : StandardMaterial3D = null) -> void:
	var weight : float = body.mass * ProjectSettings.get_setting("physics/3d/default_gravity")
	var sus : Array[Vector3]
	var i : int = 0
	var d : Dictionary
	
	var spring_distance_max_in = vehicleParams.spring_distance_max_in
	var spring_distance_max_out = vehicleParams.spring_distance_max_out
	var spring_constant = vehicleParams.spring_constant
	var spring_damping = vehicleParams.spring_damping
	
	rightTracks.initialise()
	d = rightTracks.init_suspensions(weight, spring_distance_max_in, spring_distance_max_out, spring_constant, spring_damping)
	sus.resize(d.size())
	for j in d:
		sus[i] = d[j].global_position
		i += 1
		
	leftTracks.initialise()
	d = leftTracks.init_suspensions(weight, spring_distance_max_in, spring_distance_max_out, spring_constant, spring_damping)
	sus.resize(sus.size() + d.size())
	for j in d:
		sus[i] = d[j].global_position
		i += 1
		
	for v in sus:
		centerVector += v
	centerVector /= sus.size()
	
func apply_material_override(material : StandardMaterial3D):
	
	pass

func update_suspension(body : RigidBody3D, delta: float, vehicle_rotation: Quaternion) -> bool:
	var contact_left: bool
	var contact_right: bool
	contact_left = leftTracks.update_suspension(delta, body, vehicle_rotation)
	contact_right = rightTracks.update_suspension(delta, body, vehicle_rotation)
	return contact_right && contact_left

func update_wheel_speed(body : RigidBody3D) -> void:
	var speed = body.linear_velocity.project(to_global(-basis.z)).length()
	var vAngle = (-basis.z).angle_to(body.linear_velocity)
	if vAngle > PI/2:
		speed *= -1
	
	leftTracks.update_speed(speed)
	rightTracks.update_speed(speed)

func die() -> void:
	pass
