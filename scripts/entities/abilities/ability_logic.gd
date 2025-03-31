class_name AbilityLogic
extends Node


func execute_logic(ability : Ability, hardpoint_node : Node3D, shooter : Entity, damage : float, secondary_damage : float, modifiers : Array[ModifierData]):
	var projectile : Projectile = ability.projectile_scene.instantiate() as Projectile
	projectile.ability_resource = ability
	projectile.shooter = shooter
	projectile.damage = damage
	projectile.secondary_damage = secondary_damage
	projectile.modifier_payload = modifiers
	
	get_tree().get_root().add_child(projectile)
	projectile.global_position = hardpoint_node.global_position
	projectile.global_basis = hardpoint_node.global_basis
	
	projectile.start()
