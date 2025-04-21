class_name EffectObject_OnHit_Ricochet
extends EffectObject

var effect : Effect_OnHit_Ricochet
var ricochets_left : int

func _ready() -> EffectObject_OnHit_Ricochet:
	ricochets_left = effect.max_ricochets
	return self
	

func trigger_effect():
	return
