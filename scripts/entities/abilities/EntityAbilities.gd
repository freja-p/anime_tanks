class_name EntityAbilities
extends Node

var abilities : Array[AbilityExecutor]
var _ready_abilities : Array[AbilityExecutor]
var _weights : int = 0
var _ready_weights : int = 0
	
func add_ability(new_ability : AbilityExecutor) -> void:
	_insert_ability(new_ability, abilities)
	_insert_ability(new_ability, _ready_abilities)
	
	var new_weight : int = new_ability.get_weight()
	_weights += new_weight
	_ready_weights += new_weight
	
	new_ability.ability_activated.connect(_on_ability_activated)
	new_ability.ability_ready.connect(_on_ability_ready)
	
func _insert_ability(ability : AbilityExecutor,  arr : Array[AbilityExecutor]) -> void:
	var weight : int = ability.get_weight()
	var new_i : int = arr.size()
	for i in range(arr.size()):
		if weight > arr[i].get_weight():
			new_i = i
			break
	arr.insert(new_i, ability)
	
func pick_random() -> AbilityExecutor:
	var randInt : int = randi_range(0, _weights - 1)
	for ability in abilities:
		if randInt < ability.get_weight():
			return ability
		randInt -= ability.get_weight()
	
	return null
	
func pick_random_ready() -> AbilityExecutor:
	if _ready_abilities.is_empty():
		return null
	var randInt : int = randi_range(0, _ready_weights - 1)
	for ability in _ready_abilities:
		if randInt < ability.get_weight():
			return ability
		randInt -= ability.get_weight()
	
	return null

func has_ready_abilities() -> bool:
	return not _ready_abilities.is_empty()

func _on_ability_activated(ability : AbilityExecutor):
	if _ready_abilities.has(ability):
		_ready_abilities.erase(ability)
		_ready_weights -= ability.get_weight()
	
func _on_ability_ready(ability : AbilityExecutor):
	_insert_ability(ability, _ready_abilities)
	_ready_weights += ability.get_weight()
