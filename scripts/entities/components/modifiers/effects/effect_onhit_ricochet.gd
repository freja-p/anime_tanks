class_name Effect_OnHit_Ricochet
extends Effect_OnHit

@export var max_ricochets : int = 3
@export var originate_from_entity_center : bool = false
@export var projectile_scene : PackedScene

func trigger_effect(entity_hit : Entity, hit_position : Vector3):
	var projectile : Projectile = projectile_scene.instantiate() as Projectile
	return
