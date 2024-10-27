class_name Cooldown
extends Node
## !! DO NOT INSTANTIATE !! This class is an interface to manage ability cooldowns

var stat_calculator : StatCalculator
var cooldown_resource : CooldownResource
var ability_resource : Ability

signal cooldown_ended 

func initialise():
	pass
	
func ready_to_activate() -> bool:
	return true
	
func start_cooldown() -> bool:
	return true

func get_cooldown_max() -> float:
	return 0.0
	
func get_cooldown_current() -> float:
	return 0.0
