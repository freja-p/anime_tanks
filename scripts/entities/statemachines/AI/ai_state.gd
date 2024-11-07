class_name AiState
extends StateInterface

var navigator : Navigator
var entity : Entity_Vehicle
var threat_analyzer : ThreatAnalyzer
var root : AiStateMachine


func pick_random_destination(center : Vector3 = entity.global_position, radius_max : float = 20, radius_min : float = 0) -> Vector3:
	var newPoint : Vector3 = center
	var randRadius : float = (radius_max - radius_min) * sqrt(randf()) + radius_min
	var randAngle : float = randf() * 2 * PI
	
	newPoint.x = newPoint.x + randRadius * cos(randAngle)
	newPoint.z = newPoint.z + randRadius * sin(randAngle)
	
	return newPoint
