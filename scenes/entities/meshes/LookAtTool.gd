@tool
extends MeshInstance3D

@onready var wheel = get_parent().get_node("Wheel_Single")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(wheel.global_position)
