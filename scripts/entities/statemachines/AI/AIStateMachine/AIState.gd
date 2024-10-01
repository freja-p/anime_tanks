class_name AIState
extends Node

var aiStats : AIStats
var varStore : AIVariableStore
var parentEntity : Entity

func setup() -> void:
	pass
	
func enter() -> void:
#	print("AI: %s" % self.name)
	pass

func exit() -> void:
	pass

func process_frame(delta : float) -> AIState:
	return null

func process_physics(delta : float) -> AIState:
	return null

func integrate_forces(state : PhysicsDirectBodyState3D) -> AIState:
	return null
	
func select_point_in_radius(position : Vector3, radius : float) -> Vector3:
	var newPoint : Vector3 = position
	if is_zero_approx(radius) or radius < 0:
		return newPoint
		
	# https://stackoverflow.com/questions/5837572/generate-a-random-point-within-a-circle-uniformly
	var randRadius : float = radius * sqrt(randf())
	var randAngle : float = randf() * 2 * PI
	
	newPoint.x = newPoint.x + randRadius * cos(randAngle)
	newPoint.z = newPoint.z + randRadius * sin(randAngle)
	
	return newPoint
