extends Camera3D


@export var camYoffset : float = 3
@export var camZoffset : float = 8

var raycast_result : Dictionary
var anchorPoint : Vector3
var anchorBasis : Basis
var lookTarget : Node3D

var cursorTarget : Vector3
var targetRot : Vector3
var cursorRay : RayCast3D
signal camera_rotated(worldPosition : Vector3)

@export var playerNode : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	cursorRay = $CursorRay
	#anchorNode.global_position = playerNode.global_position
	#anchorNode.position.y += camYoffset

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	anchorBasis = playerNode.basis
	anchorBasis.z = -anchorBasis.z
	targetRot = anchorBasis.get_euler()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cursorRay.global_rotation = targetRot
	CameraEventBus.player_cam_camera_rotated.emit(cursorRay.get_world_collision())
	$CursorAimPoint.global_position = cursorRay.get_world_collision()
	anchorPoint = playerNode.position
	anchorPoint.y += camYoffset
	position = anchorPoint + (basis.z * camZoffset)
	
	anchorBasis = anchorBasis.slerp(Basis.from_euler(targetRot), 0.1)
	basis = anchorBasis
	
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var mouseVelocity : Vector2 = event.relative
		
		targetRot.y = targetRot.y - mouseVelocity.x / 200
		if targetRot.y > PI:
			targetRot.y -= 2 * PI
		elif targetRot.y < -PI:
				targetRot.y += 2 * PI
			
		targetRot.x = clampf(targetRot.x - mouseVelocity.y / 200, deg_to_rad(-60), deg_to_rad(25))
