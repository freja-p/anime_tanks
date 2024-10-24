class_name Entity
extends RigidBody3D

@export_category("Stats") 
@export var stat_sheet : StatSheet

@export_category("Faction")
@export var faction : Faction

@export_category("Movement")
@export var vehicleStats : VehicleParameters

var dying : bool = false
signal died(entity : Entity, killer : Entity)

# Turret
@onready var turretMesh : TurretComponent = $Turret as TurretComponent

func get_hardpoint(hardPoint : Enums.Hardpoint) -> Node3D:
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
