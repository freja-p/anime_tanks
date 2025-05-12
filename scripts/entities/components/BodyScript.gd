extends Node3D

@export_category("Reference assignments")
@export var wheels : Array[Node3D]
@export var turret : Node3D

@export_category("Body attachment points")
@export var turretPoint : Node3D
@export var wheelPoints : Array[Node3D]
@export_subgroup("Equipment Hardpoints")
@export var secondaryHardpoint : Node3D
@export var specialHardpoint : Node3D
@export var internalHardpoint : Node3D


func _ready() -> void:
	turret.global_position = turretPoint.global_position
	for i in range(wheels.size()):
		wheels[i].global_position = wheelPoints[i].global_position

func get_hardpoint_node(hardpoint : Enums.HardpointType) -> Node3D:
	match hardpoint:
		Enums.HardpointType.PRIMARY:
			return null
		Enums.HardpointType.SECONDARY:
			return secondaryHardpoint
		Enums.HardpointType.SPECIAL:
			return specialHardpoint
		Enums.HardpointType.INTERNAL:
			return internalHardpoint
		_:
			print("Hardpoint not recognized in body")
			return null
