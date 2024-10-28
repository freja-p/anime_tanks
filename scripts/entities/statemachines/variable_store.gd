class_name VariableStore
extends Node3D

var variable_enums : Dictionary
var _variable_store : Dictionary

func get_required_variable(variable : int):
	if not _variable_store.has(variable):
		printerr("Variable not yet set: %s" % variable_enums.find_key(variable))
		return null
	return _variable_store[variable]

func get_variable(variable : int):
	if not _variable_store.has(variable):
		return null
	return _variable_store[variable]

func set_variable(variable : int, value):
	_variable_store[variable] = value
