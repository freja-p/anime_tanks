class_name AbilityLogic
extends Node


func execute_logic(ability : Ability, ability_origin : Node3D, shooter : Entity, damage : float, secondary_damage : float, modifier_payload : Array[ModifierData]):
	var projectile : Projectile = ability.projectile_scene.instantiate() as Projectile
	projectile.ability_resource = ability
	projectile.shooter = shooter
	projectile.damage = damage
	projectile.secondary_damage = secondary_damage
	projectile.modifier_payload = modifier_payload
	
	get_tree().get_root().add_child(projectile)
	projectile.global_position = ability_origin.global_position
	projectile.global_basis = ability_origin.global_basis
	
	projectile.start()
