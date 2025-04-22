class_name BuffData
extends Resource

@export var buff_name : String
@export var effects : Array[EffectData]

@export_category("Duration")
@export var has_duration : bool = true
@export var duration : float = 10.0
@export var remove_stacks_individually : bool = false

@export_category("Stacking")
@export var max_stacks : int = 10
