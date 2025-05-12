class_name Navigator
extends NavigationAgent3D

enum NAV_STATE {
	NORMAL,
	SPEED_OVERRIDE,
	TURNING
}

@export var body : Entity
@export var inputController : InputController_AI_Vehicle

@export_category("Navigation")
@export var max_auto_speed : float = 20
@export var curve_lookahead_distance : float = 10
@export var Kp_c : float = 1

var destination_speed_override : bool = false
var destination_speed : float = INF

var entering_curve : bool = false
var curve_speed : float

var current_waypoint : Vector3

var current_state : NAV_STATE

#func _ready():
	#CameraEventBus.player_cam_camera_rotated.connect(_on_player_cam_camera_rotated)


func _physics_process(_delta):
	if not is_navigation_finished():
		
		var next_waypoint = get_next_path_position()

		_calculate_curve_speed()
		
		if next_waypoint == current_waypoint:
			return
		
		inputController.set_target_location(next_waypoint)
		current_waypoint = next_waypoint


func navigate_to(world_pos : Vector3, arg_target_speed : float = INF):
	target_position = world_pos
	
	if is_inf(arg_target_speed):
		destination_speed_override = false
		inputController.override_speed = false
	else:
		destination_speed_override = true
		destination_speed = arg_target_speed
		inputController.override_speed = true
		inputController.target_speed_override = arg_target_speed
	
	
func _calculate_curve_speed():
	var last_waypoint = current_waypoint
	var last_vector = current_waypoint - body.global_position
	var distance_processed : float = last_vector.length()
	var curvature : float = last_vector.normalized().dot(body.global_transform.basis.z)
	var i = get_current_navigation_path_index() + 1
	var path : PackedVector3Array = get_current_navigation_path()
	var path_size : int = path.size()
	
	while i < path_size and distance_processed < curve_lookahead_distance:
		var next_vector = path[i] - last_waypoint
		curvature += last_vector.normalized().dot(next_vector.normalized())
		
		distance_processed += last_waypoint.distance_to(path[i])
		i += 1
		
	curvature /= distance_processed
	curve_speed = 1 / absf(curvature * Kp_c)
	#var turn : bool
	#if absf(curvature) < 0.2:
		#turn = false
		#_turning_override(false)
	#else:
		#turn = true
		#_turning_override(true)
		
	#print("%s | %.3f, %.3f" % [turn, curvature, curve_speed])
	
	
func _turning_override(is_turning : bool):
	if destination_speed_override:
		if is_turning:
			inputController.target_speed_override = curve_speed
		else:
			inputController.target_speed_override = destination_speed
		
	else:
		if is_turning:
			inputController.override_speed = true
			inputController.target_speed_override = curve_speed
		else:
			inputController.override_speed = false


func _on_navigation_finished():
#	inputController.set_target_location(body.global_position)
	_turning_override(false)
	
	
func _on_path_changed():
	inputController.set_target_location(get_next_path_position())


## TEMPORARY DEBUG CODE
#var lookpos : Vector3
#func _unhandled_input(event):
	#if event.is_action_pressed("primary_ability"):
		#navigate_to(lookpos, 15)
#func _on_player_cam_camera_rotated(worldPos : Vector3):
	#lookpos = worldPos
