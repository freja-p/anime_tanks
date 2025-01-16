class_name Projectile
extends Node3D

var shooter : Entity
var damage : float
var secondary_damage : float
var dying : bool = false
var ability_resource : Ability

var modifier_payload : Array[ModifierData] = []

func _die():
	dying = true

func hitbox_intersected(hitbox : Hitbox):
	hitbox.hit(damage, shooter, modifier_payload)
