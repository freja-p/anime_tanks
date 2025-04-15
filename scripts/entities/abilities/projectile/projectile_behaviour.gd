class_name ProjectileBehaviour
extends Node3D
## Short lived logic that may instantiate scenes which
## directly interact with the 3D space, or modify other active behaviours. 
## All behaviours must have a definite end by emitting the behaviour_ended signal

signal behaviour_ended(behaviour : ProjectileBehaviour)

var projectile_behaviour_data : ProjectileBehaviourData
var projectile_origin : ProjectileBase

func _ready_behaviour() -> void:
	return
	
func _process_behaviour(delta: float) -> void:
	return
	
func _physics_process_behaviour(delta: float) -> void:
	return
