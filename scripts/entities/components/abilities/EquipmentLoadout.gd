class_name EquipmentLoadout
extends Node

## Entity component for ability management
##
## Maintains the list of active equipment abilities available to the vehicle
## and allows other components to use the abilities

signal equipment_set(executor : AbilityExecutor)

@export var bodyComponent : Node3D
@export var modifierHandler : BuffTracker
@export var stat_calculator : StatCalculator

var _equipped : Dictionary	


func _ready():
	modifierHandler.buff_added.connect(_on_buff_added)
	modifierHandler.buff_removed.connect(_on_buff_removed)


func set_equipment(hardpoint : Enums.Hardpoint, ability : Ability):
	var executor : AbilityExecutor = preload("res://scenes/entities/components/abilities/AbilityExecutor.tscn").instantiate()
	executor.construct(ability, hardpoint, get_parent() as Entity, stat_calculator)
	executor.name = ability.ability_name
	executor.stat_calculator = stat_calculator
	_equipped[hardpoint] = executor
	add_child(executor)

	return executor

func set_equipment_loadout(loadout : Loadout):
	for hardpoint in Enums.Hardpoint.values():
		var ability = loadout.get_ability(hardpoint)
		if ability:
			set_equipment(hardpoint, ability)


func get_equipment(hardpoint : Enums.Hardpoint) -> AbilityExecutor:
	return _equipped[hardpoint]


func activate_equipment(hardpoint: Enums.Hardpoint, toggle_on : bool = true) -> bool:
	if not _equipped.has(hardpoint):
		return false
	return _equipped[hardpoint].activate(toggle_on)


func _on_buff_added(modifier : BuffData):
	for effect in modifier.effects:
		if effect is Effect_AttachModToProjectile:
			_equipped[effect.hardpoint_affected].modifiers.append(effect.modifier_attached)


func _on_buff_removed(modifier : BuffData):
	for effect in modifier.effects:
		if effect is Effect_AttachModToProjectile:
			_equipped[effect.hardpoint_affected].modifiers.erase(effect.modifier_attached)
