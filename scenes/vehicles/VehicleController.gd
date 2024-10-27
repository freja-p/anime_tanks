class_name VehicleController
extends Node

@export var steerLimitCurve : Curve
@export var steerBrakeCurve : Curve
@export var engineForceCurve : Curve
var body : VehicleBody3D

var _force_ratio := 0.0
var _brake_ratio := 0.0
var _turn_ratio := 0.0

const STEER_LIMIT = deg_to_rad(30)
const STEER_SPEED_LIMIT = 30.0
const STEER_SPEED = 1.0

const ENGINE_SPEED_LIMIT = 35
const BRAKE_FORCE = 60

var speed : float
var velocity_angle : float

var braking : bool = false

func _physics_process(delta):
	body = get_parent() as VehicleBody3D
	
	speed = body.linear_velocity.length()
	velocity_angle = body.basis.z.angle_to(body.linear_velocity)
	
	var steer_speed_limiter = steerBrakeCurve.sample(speed / STEER_SPEED_LIMIT) if braking else steerLimitCurve.sample(speed / STEER_SPEED_LIMIT)
	var steer_target = _turn_ratio * STEER_LIMIT * steer_speed_limiter
	body.steering = move_toward(body.steering, steer_target, STEER_SPEED * delta)
	
	body.engine_force = 25 * engineForceCurve.sample(speed / ENGINE_SPEED_LIMIT) * _force_ratio
	body.brake = BRAKE_FORCE * _brake_ratio
	
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
