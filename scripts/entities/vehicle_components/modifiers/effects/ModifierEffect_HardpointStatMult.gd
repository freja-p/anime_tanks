class_name ModifierEffect_HardpointStatMult
extends ModifierEffectData

@export var hardpoint_affected : Enums.Hardpoint = Enums.Hardpoint.PRIMARY
@export var stat_affected : Enums.HardpointStat = Enums.HardpointStat.MAX_AMMO
@export var multiplier_type : Enums.StatMultiplierType = Enums.StatMultiplierType.ADDITIVE
@export var intensity : float = 0.0
