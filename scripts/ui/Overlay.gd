extends Control

@export var entity : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel/DebugText.player = entity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
