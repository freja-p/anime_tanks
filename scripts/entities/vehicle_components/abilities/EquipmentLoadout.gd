class_name EquipmentLoadout
extends Node

signal equipment_set(executor : AbilityExecutor)

@export var bodyComponent : Node3D
@export var modifierHandler : ModifierHandler
@export var stat_calculator : StatCalculator

var _equipped : Dictionary	


func _ready():
	modifierHandler.modifier_added.connect(_on_modifier_added)
	modifierHandler.modifier_removed.connect(_on_modifier_removed)


func set_equipment(hardPoint : Enums.Hardpoint, ability : Ability):
	var executor = ability.create_executor(get_parent() as Entity, stat_calculator)
	executor.stat_calculator = stat_calculator
	_equipped[hardPoint] = executor
	add_child(executor)


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


func _on_modifier_added(modifier : ModifierData):
	for effect in modifier.effects:
		if effect is ModifierEffect_AttachModToProjectile:
			_equipped[effect.hardpoint_affected].modifiers.append(effect.modifier_attached)
		elif effect is ModifierEffectData_OnHit:
			pass


func _on_modifier_removed(modifier : ModifierData):
	for effect in modifier.effects:
		if effect is ModifierEffect_AttachModToProjectile:
			_equipped[effect.hardpoint_affected].modifiers.erase(effect.modifier_attached)
