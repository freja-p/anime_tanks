class_name ProjectileBase
extends Node3D
## Manages behaviours on a projectile

signal has_died()
signal behaviour_ended(ended_behaviour : ProjectileBehaviour)
signal has_hit_entity(hit_entity : Entity)

var damage : float
var modifier_payload : Array[ModifierData]

enum ProjectileState {
	ACTIVE,
	DEAD
}

var current_state : ProjectileState = ProjectileState.ACTIVE
var ability_data : Ability
var shooter : Entity
var behaviours : Array[ProjectileBehaviour]

# TODO: Distinguish between active and inactive behaviours
func _ready() -> void:
	for behaviour in behaviours:
		behaviour._ready_behaviour()
		
func _process(delta: float) -> void:
	match current_state:
		ProjectileState.ACTIVE:
			for behaviour in behaviours:
				behaviour._process_behaviour(delta)
		ProjectileState.DEAD:
			pass

func _physics_process(delta: float) -> void:
	match current_state:
		ProjectileState.ACTIVE:
			for behaviour in behaviours:
				behaviour._physics_process_behaviour(delta)
		ProjectileState.DEAD:
			pass

func add_behaviour(behaviour_data : ProjectileBehaviourData):
	var behaviour = behaviour_data.build()
	behaviour.projectile_origin = self
	behaviours.append(behaviour)
	behaviour.behaviour_ended.connect(_on_behaviour_ended)
	add_child(behaviour)
	behaviour._ready_behaviour()

func _on_behaviour_ended(behaviour : ProjectileBehaviour) -> void:
	for i in range(behaviours.size()):
		if behaviour == behaviours[i]:
			behaviours.remove_at(i)
			
			if behaviours.size() == 0:
				current_state = ProjectileState.DEAD
				queue_free()
			return
	return
