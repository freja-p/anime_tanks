class_name VFX
extends Node3D

var start_point : Vector3
var end_point : Vector3

var end_animation_callback : Callable
var vfx_data : VFXData

func play(start_point : Vector3, initial_basis : Basis,  end_point : Vector3 = start_point) -> void:
	global_position = start_point
	global_basis = initial_basis
	pass
