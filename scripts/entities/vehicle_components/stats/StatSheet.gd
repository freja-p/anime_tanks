class_name StatSheet
extends Resource

@export_category("Entity Base Stats")
@export var hp : float = 100

var stat_to_value : Dictionary

func _init():
	stat_to_value[Enums.Stat.MAX_HP] = hp

func get_stat_value(stat : Enums.Stat):
	return stat_to_value[stat]
