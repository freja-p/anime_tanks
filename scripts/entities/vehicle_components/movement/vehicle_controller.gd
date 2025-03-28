class_name VehicleController
extends Node

const STEER_HARD_LIMIT : float = deg_to_rad(30)
const STEER_SPEED_LIMIT : float = 25.0
const STEER_SPEED : float = 1.0

const ENGINE_SPEED_LIMIT : float = 35.0
const BRAKE_FORCE : float = 60.0

@export var steerLimitCurve : Curve
@export var steerBrakeCurve : Curve
@export var engineForceCurve : Curve

var _body : VehicleBody3D

var speed : float
var velocity_angle : float

var braking : bool = false

var _force_ratio : float = 0.0
var _brake_ratio : float = 0.0
var _turn_ratio : float = 0.0

func _physics_process(delta):
	_body = get_parent() as VehicleBody3D
	
	speed = _body.linear_velocity.length()
	velocity_angle = _body.basis.z.angle_to(_body.linear_velocity)
	
	#var steer_speed_limiter : float
	#if braking:
		#steer_speed_limiter = steerBrakeCurve.sample(speed / STEER_SPEED_LIMIT)  
	#else: 
		#steer_speed_limiter = steerLimitCurve.sample(speed / STEER_SPEED_LIMIT)
	var steer_speed_limiter = steerLimitCurve.sample(speed / STEER_SPEED_LIMIT)
	var steer_target = min(_turn_ratio,steer_speed_limiter) * STEER_HARD_LIMIT
	steer_target = _turn_ratio * STEER_HARD_LIMIT
	_body.steering = move_toward(_body.steering, steer_target, STEER_SPEED * delta)
	
	_body.engine_force = 25 * engineForceCurve.sample(speed / ENGINE_SPEED_LIMIT) * _force_ratio
	_body.brake = BRAKE_FORCE * _brake_ratio
	
	
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
	
