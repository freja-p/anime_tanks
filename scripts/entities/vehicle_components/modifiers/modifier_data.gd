class_name ModifierData
extends Resource

@export var modifier_name : String
@export var effects : Array[EffectData]
@export var context : ModifierContext
@export var max_stacks : int = 1

#func has_effect_type(type : Enums.EffectType):
	#for effect in effects:
		#if effect.has_effect_type(type):
			#return true
	#return false
#
#func append_effects_of_type(effect_type : Enums.EffectType, effects_with_type : Array[EffectData]):
	#for effect in effects:
		#if effect.has_effect_type(effect_type):
			#effects_with_type.append(effect)
	#return
