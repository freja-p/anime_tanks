class_name Effect_OnHit
extends EffectData

@export var affects_hardpoints : bool = false
@export var hardpoint_affected : Enums.Hardpoint = Enums.Hardpoint.PRIMARY

func trigger_effect(entity_hit : Entity, hit_position : Vector3):
	return
