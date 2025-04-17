class_name ExplosionVFX
extends VFX

var tween_scale : Tween
var tween_transparency : Tween

@onready var mesh_instance_3d : MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	mesh_instance_3d.mesh.radius = vfx_data.radius
	mesh_instance_3d.mesh.height = 2 * vfx_data.radius

func play() -> void:
	tween_scale = create_tween()
	tween_scale.tween_property(mesh_instance_3d, "scale", Vector3(1.0, 1.0, 1.0), vfx_data.duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	if end_animation_callback:
		tween_scale.tween_callback(end_animation_callback)
	tween_scale.tween_callback(queue_free)
	tween_transparency = create_tween()
	tween_transparency.tween_property(mesh_instance_3d, "transparency", 1.0, vfx_data.duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	
	tween_scale.play()
	tween_transparency.play()
