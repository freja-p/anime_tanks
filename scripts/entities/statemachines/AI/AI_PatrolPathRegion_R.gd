class_name AI_PatrolPathRegion_R
extends Resource

@export_category("Patrol Pathing")
@export var patrolPoints : Curve3D
@export var radius : float = -1
@export var patrolRelativeToPosition = false

@export_category("Overwatch Wait")
@export var overwatchAngleDegrees : float = 30
@export var overwatchDuration : float = 5
@export var overwatchAfterEachPath : bool = false
@export var overwatchAfterEndOfPath : bool = false

func get_point(index : int) -> Vector3:
	var newPoint : Vector3 = patrolPoints.get_point_position(index)
	if radius < 0:
		return newPoint
		
	# https://stackoverflow.com/questions/5837572/generate-a-random-point-within-a-circle-uniformly
	var randRadius : float = radius * sqrt(randf())
	var randAngle : float = randf() * 2 * PI
	
	newPoint.x = newPoint.x + randRadius * cos(randAngle)
	newPoint.z = newPoint.z + randRadius * sin(randAngle)
	
	return newPoint

func is_index_valid(index : int) -> bool:
	return index < patrolPoints.point_count
