class_name Cooldown
extends Node

signal cooldown_ended 

var stat_calculator : StatCalculator
var cooldown_resource : CooldownResource
var ability_resource : Ability
var hardpoint : Enums.Hardpoint
	
func ready_to_activate() -> bool:
	return true
	
	
func start_cooldown() -> bool:
	return true


func get_cooldown_max() -> float:
	return 0.0
	
	
func get_cooldown_current() -> float:
	return 0.0
