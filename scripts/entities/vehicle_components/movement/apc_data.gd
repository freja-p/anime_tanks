class_name APCData
extends Resource

@export_category("Vehicle Physics")
@export var mass : float = 5000
@export var physics_material_override : PhysicsMaterial 

@export_category("Limiters")
@export_range(0, 90, 0.1, "radians_as_degrees") var STEER_HARD_LIMIT : float = deg_to_rad(30)
@export var STEER_SPEED_LIMIT : float = 25.0
@export var STEER_SPEED : float = 1.0

@export var ENGINE_SPEED_LIMIT : float = 35.0
@export var BRAKE_FORCE : float = 60.0

@export_category("Wheel Physics")
@export var roll_influence : float = 0.5
@export var rest_length : float = 0.075
@export_category("Wheel Suspension")
@export var stiffness : float = 40
@export var max_force : float = 37500
@export_range(0.0, 1.0, 0.01) var compression = 0.5
@export_range(0.0, 1.0, 0.01) var relaxation = 0.6

@export_group("Steering Wheels" , "sw_")
@export var sw_friction_slip : float = 10.5

@export_group("Drive Wheels" , "dw_")
@export var dw_friction_slip : float = 10.5
