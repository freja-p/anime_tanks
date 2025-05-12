class_name ProjectileBase
extends Node3D
## Manages behaviours on a projectile

signal has_died()
signal behaviour_ended(ended_behaviour : ProjectileBehaviour)
signal has_hit_entity(hit_entity : Entity)
signal projectile_collided(result : Dictionary, is_body_collision : bool, behaviour : ProjectileBehaviour)

enum ProjectileState {
	INACTIVE,
	ACTIVE,
	DEAD,
}

var current_state : ProjectileState = ProjectileState.INACTIVE
var ability_data : Ability

var behaviours : Array[ProjectileBehaviour]
var listener_behaviours : Array[ProjectileListenerBehaviour]

var shooter : Entity_Vehicle
var stat_calculator : StatCalculator
var hardpoint : Enums.HardpointType
var modifier_payload : Array[BuffData]
var damage : float


func start_behaviours() -> void:
	for behaviour in behaviours:
		behaviour._ready_behaviour()
		
	for behaviour in listener_behaviours:
		behaviour._ready_behaviour()
		
	current_state = ProjectileState.ACTIVE
		

func _process(delta: float) -> void:
	match current_state:
		ProjectileState.ACTIVE:
			for behaviour in behaviours:
				behaviour._process_behaviour(delta)
			for behaviour in listener_behaviours:
				behaviour._process_behaviour(delta)
		ProjectileState.DEAD:
			pass

func _physics_process(delta: float) -> void:
	match current_state:
		ProjectileState.ACTIVE:
			for behaviour in behaviours:
				behaviour._physics_process_behaviour(delta)
			for behaviour in listener_behaviours:
				behaviour._physics_process_behaviour(delta)
		ProjectileState.DEAD:
			pass

func add_behaviour(behaviour_data : ProjectileBehaviourData):
	var behaviour = behaviour_data.build()
	behaviour.projectile_origin = self
	
	if behaviour is ProjectileListenerBehaviour:
		listener_behaviours.append(behaviour)
	else:
		behaviours.append(behaviour)
		
	behaviour.behaviour_ended.connect(_on_behaviour_ended.bind(behaviour))
	add_child(behaviour)
	
	if is_inside_tree():
		behaviour._ready_behaviour()

func add_active_behaviour(behaviour : ProjectileBehaviour) -> void:
	behaviour.projectile_origin = self
	behaviours.append(behaviour)
	behaviour.behaviour_ended.connect(_on_behaviour_ended.bind(behaviour))

func _on_behaviour_ended(behaviour : ProjectileBehaviour) -> void:
	if behaviour is ProjectileListenerBehaviour:
		for i in range(listener_behaviours.size()):
			if behaviour == listener_behaviours[i]:
				listener_behaviours.remove_at(i)
				return
		return

	for i in range(behaviours.size()):
		if behaviour == behaviours[i]:
			behaviours.remove_at(i)
			
			if behaviours.size() == 0:
				current_state = ProjectileState.DEAD
				queue_free()
			return
	return

func _end_projectile() -> void:
	get_tree().create_timer(1.0).timeout.connect(queue_free)
