class_name VehicleStats
extends Node

@export_category("Movement")
@export var accel : float = 15.0
@export var accelVelocityCurve : Curve
@export var minSpeed : float = 0.5
@export var maxSpeed : float = 10.0
@export var frictionMult : float = 10.0
@export var brakeAccel : float = 10.0
@export var engineBrakeAccel : float = 5.0

@export var forceYOffset : float = -0.3
@export var forceXOffset : float = 0.0

@export_category("Turning")
@export var maxTurnRate : float = 1.0
@export var angularAccel : float = 80.0
@export var angularDrag : float = 50.0
@export var moveAndTurnThresholdDegrees : float = 5.0
@export var maxAngleThreshold : float = 1.0

@export_category("Navigation")
@export var targetDistanceThreshold : float = 5.0
