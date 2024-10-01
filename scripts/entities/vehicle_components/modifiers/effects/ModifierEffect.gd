class_name ModifierEffectData
extends Resource

var effect_type : Enums.EffectType = Enums.EffectType.DAMAGE_OVER_TIME

var effects_map = {
	Enums.EffectType.DAMAGE_OVER_TIME : ModifierEffect_DoT
}
