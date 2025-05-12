class_name StatCalculator
extends Node
## Entity component for providing up to date stat values
##
## Provides the most current values of entity stats

class Stat:
	var effects : Dictionary[EffectData, int]

class HardpointStat:
	var stats : Dictionary[Enums.HardpointStat, Stat]
	func effects(stat : Enums.HardpointStat) -> Dictionary[EffectData, int]:
		return stats[stat].effects

# Maybe revisit some form of dual key hashmap datastruct in the future
#class Hardpoint_Stat:
	#var hardpoint : Enums.HardpointType
	#var stat : Enums.HardpointStat
	#var key : int :
		#get():
			#return hardpoint * 100 + stat
		#set(_val):
			#stat = _val % 100
			#hardpoint = _val / 100

@export var buff_tracker : BuffTracker

var _stat_effects : Dictionary[Enums.Stat, Stat]
var _hardpoint_effects : Dictionary[Enums.HardpointType, HardpointStat]

func _ready():
	buff_tracker.buff_added.connect(_on_new_buff_added)
	buff_tracker.buff_removed.connect(_on_buff_removed)
#
	for stat in Enums.Stat.values():
		_stat_effects[stat] = Stat.new()
		
	for hardpoint in Enums.HardpointType.values():
		_hardpoint_effects[hardpoint] = HardpointStat.new()
		for stat in Enums.HardpointStat.values():
			_hardpoint_effects[hardpoint].stats[stat] = Stat.new()
			
			
func get_stat(base_value : float, stat : Enums.Stat) -> float:
	return _calculate_stat(base_value, stat, -1, -1)
	
	
func get_hardpoint_stat(base_value : float, hardpoint : Enums.HardpointType, hardpoint_stat : Enums.HardpointStat)  -> float:
	return _calculate_stat(base_value, -1, hardpoint, hardpoint_stat )
	
	
func _calculate_stat(
		base_value : float, 
		stat : Enums.Stat,
		hardpoint : Enums.HardpointType, 
		hardpoint_stat : Enums.HardpointStat) -> float:
			
	var multipliers : Dictionary[EffectData, int]
	if stat > -1:
		multipliers = _stat_effects[stat].effects
	elif hardpoint > -1 and hardpoint_stat > -1:
		multipliers = _hardpoint_effects[hardpoint].effects(hardpoint_stat)
	else:
		print("Error, invalid arguments provided to calculate_stat() at %s" % self)
		return 0
	
	var flat : float = 0.0
	var additive : float = 1.0
	var multiplicative : float = 1.0
	
	for mult in multipliers.keys():
		match mult.multiplier_type:
			Enums.StatMultiplierType.FLAT:
				flat += mult.intensity * multipliers[mult]
			Enums.StatMultiplierType.ADDITIVE:
				additive += mult.intensity * multipliers[mult]
			Enums.StatMultiplierType.MULTIPLICATIVE:
				multiplicative *= mult.intensity * multipliers[mult]
	
	return (base_value + flat) *  additive  * multiplicative
	
	
func _on_new_buff_added(modifier : BuffData, count : int):
	for effect in modifier.effects:
		if effect is Effect_StatMult:
			var effects : Dictionary[EffectData, int] = _stat_effects[effect.stat_affected].effects
			if effects.has(effect):
				effects[effect] += 1
			else:
				effects[effect] = 1
		
		elif effect is Effect_HardpointStatMult:
			var effects : Dictionary[EffectData, int] = _hardpoint_effects[effect.hardpoint_affected].effects(effect.stat_affected)
			if effects.has(effect):
				effects[effect] += 1
			else:
				effects[effect] = 1
				
				
func _on_buff_removed(modifier : BuffData, count : int):
	for effect in modifier.effects:
		if effect is Effect_StatMult:
			var effects : Dictionary[EffectData, int] = _stat_effects[effect.stat_affected].effects
			if effects.has(effect):
				effects[effect] -= 1
				if effects[effect] == 0:
					effects.erase(effect)
			else:
				printerr("Error: %s tried to remove non-existent effect %s" % [self, effect])
		
		elif effect is Effect_HardpointStatMult:
			var effects : Dictionary[EffectData, int] = _hardpoint_effects[effect.hardpoint_affected].effects(effect.stat_affected)
			if effects.has(effect):
				effects[effect] -= 1
				if effects[effect] == 0:
					effects.erase(effect)
			else:
				printerr("Error: %s tried to remove non-existent effect %s" % [self, effect])


# TEMPORARY DEBUG CODE
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_f5"):
		print("Current HP: %.2f" % get_stat(100, Enums.Stat.MAX_HP))
