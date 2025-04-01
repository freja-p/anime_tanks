class_name WheelArrays
extends Node

@export var susArms : Array[MeshInstance3D]
@export var wheels : Array[MeshInstance3D]
@export var suspensionHinges : Node3D
@export var suspensionNamePattern : String = "WheelSus(\\d)"
@export var wheelNamePattern : String = "Wheel_\\w+(\\d)"
var suspensions : Dictionary
var meshSuspensions : Dictionary

func _ready():
	var nodes = suspensionHinges.get_children()
	var susNameRegex : RegEx = RegEx.create_from_string("WheelSus(\\d)")
	var wheelNameRegex : RegEx = RegEx.create_from_string(wheelNamePattern)

	for node in nodes:
		if node is WheelSuspension:
			var result : RegExMatch = susNameRegex.search(node.name)
			if result:
				var i = result.get_string(1).to_int() - 1
				suspensions[i] = node
				for node_w in nodes:
					result = wheelNameRegex.search(node_w.name)
					if result && result.get_string(1).to_int() == i:
						suspensions[i].position = node_w.position
						break
	for node in nodes:
		var result = wheelNameRegex.search(node.name)
		if result && not result.get_string(1).to_int() - 1 in suspensions:
			var newRay : RayCast3D = RayCast3D.new()
			suspensionHinges.add_child(newRay)
			newRay.global_position = node.global_position
			newRay.name = "FalseSuspension%s" % result.get_string(1)
			meshSuspensions[result.get_string(1).to_int() - 1] = newRay

func get_susArms() -> Array[MeshInstance3D]:
	return susArms
	
func get_wheels() -> Array[MeshInstance3D]:
	return wheels

func get_suspensions() -> Dictionary:
	return suspensions

func get_meshSuspensions() -> Dictionary:
	return meshSuspensions

func get_suspensionhinges() -> Node3D:
	return suspensionHinges
