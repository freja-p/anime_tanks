class_name APCData
extends Resource

@export_category("Vehicle Body Physics")
@export var mass : float = 5000
@export var physics_material_override : PhysicsMaterial 
@export var steerLimitCurve : Curve
@export var enginePowerCurve : Curve

@export_category("Constants")
@export_range(0, 90, 0.1, "radians_as_degrees") var STEER_HARD_LIMIT : float = deg_to_rad(30)
@export var STEER_SPEED : float = 1.0
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
