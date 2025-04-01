class_name WheelMeshScript
extends Node

@export var susArm : MeshInstance3D
@export var wheel : MeshInstance3D

func update_wheel_pos(relPosition : Vector3):
	relPosition.x = wheel.position.x
	relPosition.z = wheel.position.z
	wheel.position = relPosition
	
	var bas : Basis
	bas.z = relPosition.direction_to(susArm.position)
	bas.x = susArm.basis.x
	bas.y = bas.z.cross(bas.x)
	susArm.basis = bas
