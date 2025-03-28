class_name ModifierHandler
extends Node
## Entity Component for tracking active modifiers
## 
## Collects and maintains the list of active [Modifier]s on an [Entity]
## This class is the first object that will receive any _modifiers applied to it 
## from any source, regardless if it comes from an external source or the entity
## itself. 

signal modifier_added(modifier : ModifierData)
signal modifier_removed(modifier : ModifierData)

@export var owner_entity : Entity
@export var test_mod : ModifierData

var _modifiers : Dictionary

func get_modifier(modifier_data : ModifierData) -> Modifier:
	if _modifiers.has(modifier_data):
		return _modifiers[modifier_data]
	return null
	
	
func add_modifier(new_modifier : ModifierData):
	if not new_modifier:
		print("Error: No modifier received to add")
		
	var current_mod : Modifier = get_modifier(new_modifier)
	var stack_added : bool = false
	
	if current_mod:
		stack_added = current_mod.add_stack()
	else:
		_modifiers[new_modifier] = Modifier.new(new_modifier, self)
		stack_added = true
		print("%s added modifier %s" % [owner_entity, new_modifier.modifier_name])
		
	if stack_added:
		modifier_added.emit(new_modifier)
	
	
func remove_modifier(modifier_to_remove : ModifierData):
	if modifier_to_remove not in _modifiers:
		print("Modifier to remove [%s] not found" % modifier_to_remove.modifier_name)
		return
	
	var modifier_was_removed : bool = _modifiers[modifier_to_remove].remove_stack()
	if modifier_was_removed:
		_modifiers.erase(modifier_to_remove)
		print("%s removed modifier %s" % [owner_entity, modifier_to_remove.modifier_name])
	else:
		print("%s reduced modifier stack %s by 1" % [owner_entity,modifier_to_remove.modifier_name] )
	
	modifier_removed.emit(modifier_to_remove)
	

func _create_timer(context : ModifierContext) -> Timer:
	var timer : Timer = Timer.new()

	timer.name = context.to_string()
	add_child(timer)
	
	timer.start(context.duration)

	return timer


func _modifier_context_duration_timeout(modifier : Modifier):
	remove_modifier(modifier.modifier_resource)
	
	
	# TEMPORARY DEBUG CODE
func _unhandled_input(event):
	if event.is_action_pressed("debug_f3"):
		add_modifier(test_mod)
	elif event.is_action_pressed("debug_f4"):
		remove_modifier(test_mod)
		
		
#func get_hardpoint_stat_effects(hardpoint : Enums.Hardpoint, hardpoint_stat : Enums.HardpointStat):
	#return
	#
	#
#func get_abilty_stat_effects_on(hardpoint) -> Array[ModifierEffectData]:
	#var effects : Array[ModifierEffectData] = []
	#for modifier in _modifiers:
		#for effect in modifier.effects:
			#if effect.affects_ability_on(hardpoint):
				#effects.append(effect)
	#return effects
#
#
#func get_effects_of_type(effect_type : Enums.EffectType) -> Array[ModifierEffectData]:
	#var effects : Array[ModifierEffectData] = []
	#for mod in _modifiers:
		#mod.append_effects_of_type(effect_type, effects)
	#return effects
