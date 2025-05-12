class_name Entity
extends RigidBody3D

signal died(entity : Entity, killer : Entity)

@export_category("Faction")
@export var faction : Faction

var dying : bool = false

# Turret
@onready var turretMesh : TurretComponent = $Turret as TurretComponent

func get_hardpoint(hardPoint : Enums.HardpointType) -> Node3D:
	var hardPointNode = get_node("Body").get_hardpoint_node(hardPoint)
	if not hardPointNode:
		hardPointNode = get_node("Turret").get_hardpoint_node(hardPoint)
		
	if not hardPointNode:
		print("No hardpoint found")
		return null
	return hardPointNode

func get_target_point() -> Vector3:
	return get_barrel_aim()

func get_barrel_aim() -> Vector3:
	return get_node("Turret").get_barrel_aim()
