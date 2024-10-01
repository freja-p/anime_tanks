extends Control

@export var camera : Camera3D
@export var playerEntity : Node3D

var playerEntityRay : RayCast3D

func _ready():
	print("ui ready")
#	PlayerEventBus.turret_aiming_updated.connect(_on_aim_position_update)
	CameraEventBus.player_cam_camera_rotated.connect(_on_player_cam_camera_rotated)
#	playerEntityRay = playerEntity.get_barrel_ray()

func _process(delta):
	$BarrelCrosshair.position = camera.unproject_position(playerEntity.get_barrel_aim())

func _on_aim_position_update(position : Vector3):
	$BarrelCrosshair.position = camera.unproject_position(position)


func _on_player_cam_camera_rotated(worldPosition):
	$Cursor.position = camera.unproject_position(worldPosition)
