class_name EquipmentLoadout
extends Node

@export var bodyComponent : Node3D
@export var modifierHandler : ModifierHandler
@export var stat_calculator : StatCalculator
var equipped : Dictionary

func _ready():
	var parent = get_parent() as Entity_Vehicle
	if parent.primary:
		set_equipment(Enums.Hardpoint.PRIMARY, parent.primary)
	if parent.secondary:
		set_equipment(Enums.Hardpoint.SECONDARY, parent.secondary)
	if parent.special:
		set_equipment(Enums.Hardpoint.SPECIAL, parent.special)
	if parent.internal:
		set_equipment(Enums.Hardpoint.INTERNAL, parent.internal)

func set_equipment(hardPoint : Enums.Hardpoint, ability : Ability):
	var executor = ability.initialise(get_parent() as Entity)
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
	return equipped[hardpoint].activate(toggle_on)

func _on_modifier_added(modifier : ModifierData):
	var new_effects : Array[ModifierEffectData] = []
	for effect in modifier.effects:
		if effect is ModifierEffect_AttachModToProjectile:
			new_effects.append(effect.modifier_attached)
