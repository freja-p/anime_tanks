extends Node

@export var f1Spawn : PackedScene
@export var player : Entity
var aimPosition : Vector3

func _unhandled_key_input(event):
	if event.is_action_pressed("debug_spawn_enemy"):
		var newEnemy = f1Spawn.instantiate()
		newEnemy.initialise(aimPosition)
		get_parent().get_node("Map").add_child(newEnemy)
	if event.is_action_pressed("debug_kill_player"):
		if player:
			player.dying = true
	

func _on_player_cam_camera_rotated(worldPosition):
		aimPosition = worldPosition
		aimPosition.y += 1
