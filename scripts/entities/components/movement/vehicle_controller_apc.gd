class_name VehicleControllerAPC
extends VehicleController

@export var vehicle_data : APCData

# Reduces the enginePowerCurve output to make tuning the engine curve easier
const ENGINE_ACCELERATION_FACTOR : float = 0.01

var _body : VehicleBody3D

var speed : float
var velocity_angle : float

var braking : bool = false

var _force_ratio : float = 0.0
var _brake_ratio : float = 0.0
var _turn_ratio : float = 0.0


func _ready() -> void:
	if vehicle_data:
		update_vehicle_data(vehicle_data)
	
	
func _physics_process(delta) -> void:
	_body = get_parent() as VehicleBody3D
	
	speed = _body.linear_velocity.length()
	velocity_angle = _body.basis.z.angle_to(_body.linear_velocity)

	var steer_speed_limiter = vehicle_data.steerLimitCurve.sample(speed)
	var steer_target = min(_turn_ratio,steer_speed_limiter) * vehicle_data.STEER_HARD_LIMIT
	steer_target = _turn_ratio * vehicle_data.STEER_HARD_LIMIT
	
	_body.steering = move_toward(_body.steering, steer_target, vehicle_data.STEER_SPEED * delta)
	_body.engine_force = _body.mass * vehicle_data.enginePowerCurve.sample(speed) * ENGINE_ACCELERATION_FACTOR * _force_ratio
	_body.brake = vehicle_data.BRAKE_FORCE * _brake_ratio
	
	
func get_wheels() -> Array[VehicleWheel3D]:
	var wheels : Array[VehicleWheel3D] = []
	for c in get_children():
		if c is VehicleWheel3D:
			wheels.append(c)
			
	return wheels
	
	
func apply_forward(forward_ratio : float):
	if is_zero_approx(forward_ratio):
		apply_engine(0)
	elif speed < 0.1:
		apply_engine(forward_ratio)
	elif velocity_angle < PI/2:
		if forward_ratio > 0:
			apply_engine(forward_ratio)
		else:
			apply_brake(absf(forward_ratio))
	else:
		if forward_ratio > 0:
			apply_brake(absf(forward_ratio))
		else:
			apply_engine(forward_ratio)
			
			
func apply_engine(force_ratio : float):
	braking = false
	_force_ratio = clampf(force_ratio, -1.0, 1.0)
	_brake_ratio = 0.0
	
	
func apply_brake(brake_ratio : float):
	braking = true
	_force_ratio = 0.0
	_brake_ratio = clampf(brake_ratio, 0.0, 1.0)
	
	
func turn(turn_ratio : float):
	_turn_ratio = -clampf(turn_ratio, -1.0, 1.0)
	
	
func update_vehicle_data(new_vehicle_data : APCData) -> void:
	var wheels : Array[VehicleWheel3D] = get_wheels()
	
	for wheel in wheels:
		wheel.wheel_roll_influence = new_vehicle_data.roll_influence
		wheel.wheel_rest_length = new_vehicle_data.rest_length
		wheel.suspension_stiffness = new_vehicle_data.stiffness
		wheel.suspension_max_force = new_vehicle_data.max_force
		wheel.damping_compression = new_vehicle_data.compression
		wheel.damping_relaxation = new_vehicle_data.relaxation
		
		if wheel.use_as_steering:
			wheel.wheel_friction_slip = new_vehicle_data.sw_friction_slip
		else:
			wheel.wheel_friction_slip = new_vehicle_data.dw_friction_slip
	
	return
