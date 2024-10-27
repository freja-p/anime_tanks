extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Vector2(0,1).normalized().dot(Vector2(10,0).normalized()))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
