class_name Loadout
extends Resource

@export_category("Equipment")
@export var primary : Ability
@export var secondary : Ability
@export var special : Ability
@export var internal : Ability
@export var artillery : Ability
@export var ultimate : Ability

func get_ability(hardpoint : Enums.HardpointType) -> Ability:
	match hardpoint:
		Enums.HardpointType.PRIMARY:
			return primary
		Enums.HardpointType.SECONDARY:
			return secondary
		Enums.HardpointType.SPECIAL:
			return special
		Enums.HardpointType.INTERNAL:
			return internal
		Enums.HardpointType.ARTILLERY:
			return artillery
		Enums.HardpointType.ULTIMATE:
			return ultimate
		_:
			print("Loadout did not recognize hardpoint: %s " % [Enums.HardpointType.keys()[hardpoint]])
			return null
