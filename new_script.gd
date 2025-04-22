extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var test : Dictionary[int, int]
	print(test[1])
	test[1] = 10
	print(test[1])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
