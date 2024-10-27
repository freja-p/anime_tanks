class_name StateInterface
extends Node

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
