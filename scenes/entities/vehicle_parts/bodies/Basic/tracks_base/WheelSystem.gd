class_name WheelSystem
extends Node3D

@export var wheel_radius = 0.35
var susArms : Array[MeshInstance3D]
var wheels : Array[MeshInstance3D]
var wheelYOffsets : Array[float]
var suspensions : Dictionary
var meshSuspensions : Dictionary
var meshMaxOut : float
var attachPointYOffset : float
var suspensionHinges : Node3D
@export var slopeRay : RayCast3D
@onready var arrays : WheelArrays = $WheelArrays as WheelArrays
@onready var trackPath : TankTrackPath = $TrackPath as TankTrackPath

func initialise():
	susArms = arrays.get_susArms()
	wheels = arrays.get_wheels()
	wheelYOffsets.resize(wheels.size())
	for i in range(wheels.size()):
		wheelYOffsets[i] = wheels[i].position.y
	suspensions = arrays.get_suspensions()
	meshSuspensions = arrays.get_meshSuspensions()
	suspensionHinges = arrays.get_suspensionhinges()
	attachPointYOffset = suspensionHinges.position.y
	
	trackPath.initialise(wheelYOffsets , attachPointYOffset)

func init_suspensions(weight: float, arg_spring_distance_max_in: float, arg_spring_distance_max_out: float, arg_spring_constant: float, arg_spring_damping: float) -> Dictionary:
	meshMaxOut = arg_spring_distance_max_out
	for i in suspensions:
		# Assume equal number of real suspensions on both sides of vehicle
		suspensions[i].global_position = wheels[i].global_position
		suspensions[i].init_suspension(weight / (suspensions.size() * 2) , wheel_radius, arg_spring_distance_max_in, arg_spring_distance_max_out, arg_spring_constant, arg_spring_damping)
	
	for i in meshSuspensions:
		meshSuspensions[i].target_position = Vector3(0.0, -(arg_spring_distance_max_out + wheel_radius), 0.0)
	
	return suspensions

func update_suspension(delta: float, vehicle_body: RigidBody3D, vehicle_rotation: Quaternion) -> bool:
	var has_contact : bool = false
	for i in suspensions:
		has_contact = suspensions[i].add_spring_force(delta, vehicle_body, vehicle_rotation) || has_contact
		update_wheel_pos(suspensions[i].get_wheel_pos(), susArms[i], wheels[i], i)
	
	has_contact = slopeRay.is_colliding() || has_contact
	
	for i in meshSuspensions:
		if meshSuspensions[i].is_colliding():
			# Already accounts for local space wheel offset, so no need to add wheelYOffset
			var target = suspensionHinges.to_local(meshSuspensions[i].get_collision_point()) 
			target.y += wheel_radius
#			wheels[i].position = target
			update_wheel_pos(target, susArms[i], wheels[i], i)
		else:
			var target = Vector3(0, - (meshMaxOut - wheelYOffsets[i]), 0)
			update_wheel_pos(target, susArms[i], wheels[i], i)
	update_track_curve()
	return has_contact
	
func update_wheel_pos(relPosition : Vector3, arm : MeshInstance3D, wheel : MeshInstance3D, i : int):
	relPosition.x = wheel.position.x
	relPosition.z = wheel.position.z
	if i in suspensions: 
		# Physics suspension scene does not account for local space wheel offset, so it's added manually
#		print("%d: %f" % [i, relPosition.y])
		relPosition.y = relPosition.y + wheelYOffsets[i]

	wheel.position = relPosition
	
	var bas : Basis
	bas.z = relPosition.direction_to(arm.position)
	bas.x = arm.basis.x
	bas.y = bas.z.cross(bas.x)
	arm.basis = bas
	
func update_track_curve() -> void:
	var wheelPosArr : Array[float]
	var wheelsSize = wheels.size()
	wheelPosArr.resize(wheelsSize)
	for i in range(wheelsSize):
		wheelPosArr[i] = wheels[i].position.y
		
	trackPath.update_wheel_pos(wheelPosArr)

func update_speed(newSpeed : float) -> void:
	trackPath.update_speed(newSpeed)
