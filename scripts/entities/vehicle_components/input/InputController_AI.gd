class_name InputController_AI_Vehicle
extends IInputController

@export var body : RigidBody3D
@export var vehicleController : Node
@export var turretComponent : TurretComponent

@export_category("Speed PID Controller")
@export var _Kp : float = 1
@export var _Ki : float = 0
@export var _Kd : float = 0
@export var _dt : float = 0.01

@export_category("Steering PID Controller")
@export var min_turn_speed : float = 3
@export var max_turn_speed : float = 5
@export var _Kpt : float = 1
@export var _Kit : float = 0.5

@export_category("Distance PID Controller")
@export var distance_threshold : float = 1.0
@export var _Kpd : float = 0.01

var _prev_error : float = 0.0
var _integral : float = 0.0
var _int_max = 200

@onready var iterationTimer : Timer = $IterationTimer as Timer

var override_speed : bool = false
var target_speed_override : float = 0

var _target_is_behind : bool = false
var _target_position : Vector3
var _target_speed : float = 0

var _output_force_ratio : float = 0.0
var _output_turn_ratio : float = 0.0
var is_dying : bool = false

var target_reached : bool = false

func _ready():
	iterationTimer.wait_time = _dt
	_target_position = body.global_position
	
func _on_iteration_timer_timeout():
	if target_reached:
		_target_speed = target_speed_override
		print(target_speed_override)
		_output_turn_ratio = 0
	else:
		_calculate_distance()
		_calculate_steering()
	_calculate_speed_pid()
	
	vehicleController.apply_forward(_output_force_ratio)
	vehicleController.turn(_output_turn_ratio)
	
func _calculate_distance():
			
	if body.global_position.direction_to(_target_position).dot(body.global_transform.basis.z) < 0:
		_target_is_behind = true
	else:
		_target_is_behind = false
		
	var error = (_target_position - body.global_position).length()
	var Pout = _Kpd * error
	
	if _target_is_behind:
		# Prioritise turning to target postion over hitting the speed override
		_target_speed = clampf(Pout, min_turn_speed, max_turn_speed)
		return
	elif override_speed:
		_target_speed = target_speed_override
	elif error < distance_threshold:
		_target_speed = 0
		return
	else:
		_target_speed = Pout

func _calculate_speed_pid():
	
	var error = absf(_target_speed) - body.linear_velocity.length()
	if _target_speed < 0:
		error *= -1

	var Pout = _Kp * error
	
#	_integral += error * _dt
#	var Iout = _Ki * _integral
#
#	var derivative = (error - _prev_error) / _dt
#	var Dout = _Kd * derivative
#
#	var output = Pout + Iout + Dout
	_output_force_ratio = Pout
	
#	if _integral > _int_max:
#		_integral = _int_max
#	elif _integral < -_int_max:
#		_integral = -_int_max
#	_prev_error = error

func _calculate_steering():
	var target_angle = body.global_transform.basis.z.signed_angle_to(body.position.direction_to(_target_position), body.basis.y)
	
	var Pout = _Kpt * target_angle
	
	_integral += target_angle * _dt
	var Iout = _Ki * _integral
	
	
	_output_turn_ratio = -(Pout + Iout)

#	print("%.3f | %.3f" % [rad_to_deg(target_angle), _output_turn_ratio])
	
func set_target_location(worldPos : Vector3):
	_target_position = worldPos
	target_reached = false
	$MeshInstance3D.global_position = worldPos

func get_current_aim() -> Vector3:
	return turretComponent.get_barrel_aim()
