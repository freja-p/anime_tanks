extends Node

var vehicleReachedTarget := true
var maxRange := Vector2(40,40)
var targetPoint : Vector3
@export var navAgent : NavigationAgent3D

signal newTargetPointCalculated(worldPos : Vector3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func wait_for_command():
	var wait_time = randf_range(1, 10)
#	print("Waiting for %fs" % wait_time)
	$IdleTimer.start(wait_time)
	
func calculate_new_target():
	targetPoint = Vector3(100.0, 100.0, 100.0)
	navAgent.target_position = targetPoint
	while not navAgent.is_target_reachable():
		targetPoint = Vector3(randf_range(-maxRange.x, maxRange.x), 0, randf_range(-maxRange.y,maxRange.y))
		navAgent.target_position = targetPoint
		
#	print("New target calculated %s" % targetPoint)
	newTargetPointCalculated.emit(targetPoint)
	
func calculate_new_target_radius(maxRadius : float):
	targetPoint = Vector3(100.0,0.0,0.0)
	while targetPoint.distance_to(get_parent().global_position) > maxRadius:
		targetPoint = Vector3(randf_range(-maxRange.x, maxRange.x), 0, randf_range(-maxRange.y,maxRange.y))
#	print("New target calculated within radius %s" % targetPoint)
	newTargetPointCalculated.emit(targetPoint)
	
	
func _on_idle_timer_timeout():
	$IdleTimer.stop()
	calculate_new_target()
	
func _on_idle_entered_idle_state():
	wait_for_command()
