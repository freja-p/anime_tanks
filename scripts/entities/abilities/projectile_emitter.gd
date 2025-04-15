class_name ProjectileBase
extends Node3D
## Manages behaviours on a projectile

signal has_died()
signal behaviour_ended(ended_behaviour : ProjectileBehaviour)
signal has_hit_entity(hit_entity : Entity)

var damage : float
var modifier_payload : Array[ModifierData]

enum ProjectileState {
	INACTIVE,
	ACTIVE,
	DEAD
}

var current_state : ProjectileState = ProjectileState.INACTIVE
var ability_data : Ability
var shooter : Entity
var behaviours : Array[ProjectileBehaviour]

func start_behaviours() -> void:
	for behaviour in behaviours:
		behaviour._ready_behaviour()
	current_state = ProjectileState.ACTIVE
		
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
	
	if is_inside_tree():
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
