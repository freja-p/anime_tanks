extends IInputController

## Entity Component for controlling vehicle movement

@export var body : RigidBody3D
@export var vehicleController : Node
@export var turretComponent : TurretComponent
@export var body_component : Node3D
@export var equipmentLoadout : EquipmentLoadout

var currentAim : Vector3

func _ready():
	CameraEventBus.player_cam_camera_rotated.connect(_on_player_cam_camera_rotated)

func _unhandled_input(event : InputEvent):
	if event.is_action("primary_ability"):
		equipmentLoadout.activate_equipment(Enums.HardpointType.PRIMARY, event.is_pressed())
	elif event.is_action("secondary_ability"):
		equipmentLoadout.activate_equipment(Enums.HardpointType.SECONDARY, event.is_pressed())
	elif event.is_action("defensive_ability"):
		equipmentLoadout.activate_equipment(Enums.HardpointType.INTERNAL, event.is_pressed())
	elif event.is_action("special_ability"):
		equipmentLoadout.activate_equipment(Enums.HardpointType.SPECIAL, event.is_pressed())
	
func _physics_process(delta):
	var steer_target = Input.get_axis("move_left", "move_right")
	vehicleController.turn(steer_target)
		
	var power = Input.get_axis("move_backward", "move_forward")
	vehicleController.apply_forward(power)

func _on_player_cam_camera_rotated(worldPos : Vector3):
	turretComponent.aim_at(worldPos)
	var hardpoint : Hardpoint = body_component.get_hardpoint_node(Enums.HardpointType.SECONDARY) as Hardpoint
	hardpoint.update_target(worldPos)
	currentAim = worldPos
	
func get_current_aim() -> Vector3:
	return currentAim
