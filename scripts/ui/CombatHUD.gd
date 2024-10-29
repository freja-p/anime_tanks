extends CanvasLayer

@export var player_entity : Entity_Vehicle

@onready var hp_label: Label = %HPLabel
@onready var primary_ammobar: ProgressBar = %PrimaryAmmobar
@onready var secondary_ammo_bar: ProgressBar = %SecondaryAmmoBar

var primary_cooldown : CooldownInterface
var secondary_cooldown : CooldownInterface

func initialise() -> void :
	primary_cooldown = player_entity.equipmentLoadout.get_equipment(Enums.Hardpoint.PRIMARY).cooldown
	secondary_cooldown = player_entity.equipmentLoadout.get_equipment(Enums.Hardpoint.SECONDARY).cooldown

func _process(delta: float) -> void:
	hp_label.text = str(player_entity.health_manager.current_health)
	_update_primary_ammo()
	_update_secondary_ammo()
	
func _update_primary_ammo():
	primary_ammobar.max_value = primary_cooldown.get_cooldown_max()
	primary_ammobar.value = primary_cooldown.get_cooldown_current()

func _update_secondary_ammo():
	secondary_ammo_bar.max_value = secondary_cooldown.get_cooldown_max()
	secondary_ammo_bar.value = secondary_cooldown.get_cooldown_current()
