class_name Loadout
extends Resource
@export_category("Equipment")
@export var primary : Ability
@export var secondary : Ability
@export var special : Ability
@export var internal : Ability

func get_ability(hardpoint : Enums.Hardpoint) -> Ability:
	match hardpoint:
		Enums.Hardpoint.PRIMARY:
			return primary
		Enums.Hardpoint.SECONDARY:
			return secondary
		Enums.Hardpoint.SPECIAL:
			return special
		Enums.Hardpoint.INTERNAL:
			return internal
		_:
			print("Loadout did not recognize hardpoint: %s " % [Enums.Hardpoint.keys()[hardpoint]])
			return null
