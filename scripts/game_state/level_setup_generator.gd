class_name LevelEssentialspGenerator
extends Node

@export_category("Required")
@export var player : Entity

@export_category("Functional")
@export var main_camera : PackedScene
@export var hud_elements : Array[PackedScene]

@export_category("Enviroment")
@export var lighting : PackedScene

@onready var parent : Node = get_parent()

func _ready() -> void:
	if main_camera: parent.add_child(main_camera.instantiate())	
	for hud_element in hud_elements:
		parent.add_child(hud_element.instantiate())
	
	if lighting: parent.add_child(lighting.instantiate())

func set_variables(node : Node):
	pass
