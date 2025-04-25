class_name EquipmentLoadout
extends Node

## Entity component for ability management
##
## Maintains the list of active equipment abilities available to the vehicle
## and allows other components to use the abilities

signal equipment_set(executor : AbilityExecutor)

@export var bodyComponent : Node3D
@export var buff_tracker : BuffTracker
@export var stat_calculator : StatCalculator

var _equipped : Dictionary[Enums.Hardpoint, AbilityExecutor]


func _ready() -> void:
	buff_tracker.buff_added.connect(_on_buff_added)
	buff_tracker.buff_removed.connect(_on_buff_removed)


func set_equipment(hardpoint : Enums.Hardpoint, ability : Ability) -> void:
	var executor : AbilityExecutor = AbilityExecutor.build(ability, hardpoint, get_parent() as Entity_Vehicle)
	_equipped[hardpoint] = executor
	add_child(executor)


func set_equipment_loadout(loadout : Loadout) -> void:
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


func _on_buff_added(modifier : BuffData, stacks : int):
	for effect in modifier.effects:
		if effect is EffectHardpointAttachBuff:
			_equipped[effect.hardpoint_affected].modifiers.append_array(range(stacks).map(func(x): return effect.modifier_attached))
		elif effect is EffectHardpointAttachBehaviour:
			_equipped[effect.hardpoint_affected].behaviours.append_array(range(stacks).map(func(x): return effect.behaviour_added))

func _on_buff_removed(modifier : BuffData, stacks : int):
	for effect in modifier.effects:
		if effect is EffectHardpointAttachBuff:
			_equipped[effect.hardpoint_affected].modifiers.erase(effect.modifier_attached)
