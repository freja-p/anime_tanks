class_name EquipmentLoadout
extends Node

@export var bodyComponent : Node3D
@export var modifierHandler : ModifierHandler
@export var stat_calculator : StatCalculator
var equipped : Dictionary

signal equipment_set(executor : AbilityExecutor)

func _ready():
	modifierHandler.modifier_added.connect(_on_modifier_added)
	modifierHandler.modifier_removed.connect(_on_modifier_removed)

func set_equipment(hardPoint : Enums.Hardpoint, ability : Ability):
	var executor = ability.initialise(get_parent() as Entity, stat_calculator)
	executor.stat_calculator = stat_calculator
	equipped[hardPoint] = executor
	add_child(executor)

func set_equipment_loadout(loadout : Loadout):
	for hardpoint in Enums.Hardpoint.values():
		var ability = loadout.get_ability(hardpoint)
		if ability:
			set_equipment(hardpoint, ability)

func get_equipment(hardpoint : Enums.Hardpoint) -> AbilityExecutor:
	return equipped[hardpoint]

func activate_equipment(hardpoint: Enums.Hardpoint, toggle_on : bool = true) -> bool:
	if not equipped.has(hardpoint):
		return false
	return equipped[hardpoint].activate(toggle_on)

func _on_modifier_added(modifier : ModifierData):
	for effect in modifier.effects:
		if effect is ModifierEffect_AttachModToProjectile:
			equipped[effect.hardpoint_affected].modifiers.append(effect.modifier_attached)

func _on_modifier_removed(modifier : ModifierData):
	for effect in modifier.effects:
		if effect is ModifierEffect_AttachModToProjectile:
			equipped[effect.hardpoint_affected].modifiers.erase(effect.modifier_attached)
