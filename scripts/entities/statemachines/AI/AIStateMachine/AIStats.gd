class_name AIStats
extends Node

@export_category("Navigation")
@export var timeToFire : float = 5
@export var patrolCurve : Curve3D
@export var patrolRegionCenter : Array[Vector3] = [Vector3.ZERO]
@export var patrolRegionRadius : Array[float] = [1.0]
