class_name ExplosionVFX
extends Node3D

signal entities_hit(entity_hitboxes : Array[Hitbox])

@export var radius : float = 4
@export var duration : float = 0.4
@export var raycast_hits : bool = false

var tween_scale : Tween
var tween_transparency : Tween

@onready var mesh_instance_3d : MeshInstance3D = $MeshInstance3D
@onready var shape_cast_3d : ShapeCast3D = $ShapeCast3D

func _ready() -> void:
	mesh_instance_3d.mesh.radius = radius
	mesh_instance_3d.mesh.height = 2 * radius
	shape_cast_3d.shape.radius = radius


func explode(on_explode_end : Callable) -> void:
	tween_scale = create_tween()
	tween_scale.tween_property(mesh_instance_3d, "scale", Vector3(1.0, 1.0, 1.0), duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween_scale.tween_callback(on_explode_end)
	
	tween_transparency = create_tween()
	tween_transparency.tween_property(mesh_instance_3d, "transparency", 1.0, duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	
	tween_scale.play()
	tween_transparency.play()
	
	if raycast_hits:
		calculate_hit()


func calculate_hit():
	shape_cast_3d.force_shapecast_update()
	if shape_cast_3d.is_colliding():
		var collisions : Array[Hitbox]
		for i in shape_cast_3d.get_collision_count():
			var collider = shape_cast_3d.get_collider(i)
			if collider is Hitbox:
				collisions.append(collider)
		
		if collisions.size() > 0:
			entities_hit.emit(collisions)
