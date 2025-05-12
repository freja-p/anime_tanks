class_name TrailVFX
extends VFX

@export var trail_duration : float = 0.8
var speed : float
var skip_frames : int = 3
var target_position : Vector3

func _process(delta: float) -> void:
	if skip_frames > 0:
		skip_frames -= 1
		return
	translate(Vector3.MODEL_FRONT * speed * delta)


func play(start_point : Vector3, initial_basis : Basis,  end_point : Vector3 = start_point) -> void:
	super(start_point, initial_basis, end_point)
	look_at(end_point, Vector3.UP, true)
	target_position = end_point
	speed = start_point.distance_to(end_point) / vfx_data.duration
	get_tree().create_timer(vfx_data.duration).timeout.connect(_on_duration_end)
	get_tree().create_timer(vfx_data.duration + trail_duration).timeout.connect(_on_timer_timeout)
	
func _on_duration_end() -> void:
	global_position = target_position
	skip_frames = 10000

func _on_timer_timeout() -> void:
	queue_free()
