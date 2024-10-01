class_name WheelMeshScript_IK
extends Node3D

@onready var targetNode : Marker3D = $WheelArmature/WheelIKTarget

func update_wheel_pos(worldPos):
	targetNode.position = to_local(worldPos)
