class_name AbilityLogic
extends Node

enum SPAWNLOGIC {
	NODE3D,
	PROJECTILE,
	TARGETED_PROJECTILE,
	RIGIDBODY
}

## Honestly questioning the usefulness of this class rn
func execute_logic(ability : Ability, hardpoint_node : Node3D, shooter : Entity, damage : float, secondary_damage : float, modifiers : Array[ModifierData]):
	var logic : SPAWNLOGIC = ability.spawn_logic
	#var projectile : Projectile = create_projectile_from(ability, shooter, damage, modifiers)
	var projectile : Projectile = ability.projectile_scene.instantiate() as Projectile
	projectile.ability_resource = ability
	projectile.shooter = shooter
	projectile.damage = damage
	projectile.secondary_damage = secondary_damage
	projectile.modifier_payload = modifiers
	
	get_tree().get_root().add_child(projectile)
	projectile.initialise(hardpoint_node.global_position, hardpoint_node.global_transform.basis)
	
	#match logic:
		#SPAWNLOGIC.NODE3D:
			#node3d_spawn(projectile, hardpoint_node)
		#SPAWNLOGIC.PROJECTILE:
			#projectile_spawn(projectile, hardpoint_node)
		#SPAWNLOGIC.TARGETED_PROJECTILE:
			#targeted_projectile(projectile, hardpoint_node)
		#SPAWNLOGIC.RIGIDBODY:
			#projectile_body_spawn(projectile, hardpoint_node)

func node3d_spawn(projectile : Projectile, hardpoint_node : Node3D):
	get_tree().get_root().add_child(projectile)
	projectile.initialise(hardpoint_node.global_position, hardpoint_node.global_transform.basis)

func projectile_spawn(projectile : Projectile, hardpoint_node : Node3D):
	get_tree().get_root().add_child(projectile)
	projectile.initialise(hardpoint_node.global_position, hardpoint_node.global_transform.basis)
	
func targeted_projectile(projectile : Projectile, hardpoint_node : Node3D):
	get_tree().get_root().add_child(projectile)
	projectile.initialise(hardpoint_node.global_position, hardpoint_node.global_transform.basis)

func projectile_body_spawn(projectile : Projectile, hardpoint_node : Node3D):
	get_tree().get_root().add_child(projectile)
	projectile.initialise(hardpoint_node.global_position, hardpoint_node.global_transform.basis)

func create_projectile_from(ability : Ability, shooter : Entity, damage : float, modifiers : Array[ModifierData]) -> Projectile:
	var projectile : Projectile = ability.projectile_scene.instantiate() as Projectile
	projectile.ability_resource = ability
	projectile.shooter = shooter
	projectile.damage = damage
	projectile.modifier_payload = modifiers
	return projectile
