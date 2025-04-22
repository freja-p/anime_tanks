class_name Entity_Vehicle
extends Entity

@export var health : float = 100
@export var loadout : Loadout
# @export var vehicle_data_override : APCData

@onready var turret = %Turret
@onready var input = %InputController
@onready var equipmentLoadout = %EquipmentLoadout as EquipmentLoadout
@onready var buff_tracker: BuffTracker = $BuffTracker as BuffTracker
@onready var health_manager: HealthManager = $HealthManager
@onready var stat_calculator: StatCalculator = $StatCalculator
#@onready var entity_detector: EntityDetector = $EntityDetector
@onready var vehicle_controller: VehicleControllerAPC = $VehicleController
@onready var center : Node3D = $Center

func _ready():
	equipmentLoadout.set_equipment_loadout(loadout)


func get_barrel_aim() -> Vector3:
	return turret.get_barrel_aim()
	
	
func get_target_aim() -> Vector3:
	if input.has_method("get_current_aim"):
		return input.get_current_aim()
	return get_barrel_aim()

func get_hitboxes() -> Array[Hitbox]:
	var hitboxes : Array[Hitbox] = []
	for child in get_children():
		if child is Hitbox:
			hitboxes.append(child)
	return hitboxes
