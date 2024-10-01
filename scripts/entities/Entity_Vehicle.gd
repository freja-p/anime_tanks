class_name Entity_Vehicle
extends Entity

@export var defaultLoadout : Loadout

@onready var turret = %Turret
@onready var input = %InputController
@onready var equipmentLoadout = %EquipmentLoadout as EquipmentLoadout
@onready var modifier_handler: ModifierHandler = $ModifierHandler as ModifierHandler
@onready var health_manager: HealthManager = $HealthManager
@onready var stat_calculator: StatCalculator = $StatCalculator

func _ready():
	equipmentLoadout.set_equipment_loadout(defaultLoadout)

func get_barrel_aim() -> Vector3:
	return turret.get_barrel_aim()
	
func get_target_aim() -> Vector3:
	if input.has_method("get_current_aim"):
		return input.get_current_aim()
	return get_barrel_aim()

func hurt(damage : float):
	health_manager.hurt(damage)
