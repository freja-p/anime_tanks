class_name character_stats
extends Resource

@export_category("Base Stats")
@export var maxHealth : float = 100

@export_category("Suspension")
@export var spring_constant: float = 500000
@export var spring_damping: float = 100000
@export var spring_distance_max_in: float = 0.07
@export var spring_distance_max_out: float = 0.14
