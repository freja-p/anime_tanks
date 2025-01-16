class_name ModifierEffectData_OnHit_Explode
extends ModifierEffectData_OnHit

@export_category("Explosion Stats")
@export var radius : float = 2.0
@export var damage : float = 10

func trigger_effect(entity_hit : Entity, hit_position : Vector3):
	return
