class_name TankTrackPath
extends Path3D

@onready var trackMM : MultiMesh = $TrackMultiMesh.multimesh
@onready var linkMM : MultiMesh = $LinkMultiMesh.multimesh

@export var trackSize : float = 0.2
@export var distanceBetweenTrack : float = 0.201
@export var firstPointIdx : int = 7
@export var wheelPoints : int = 6

var offset : float
var wheelYOffsets : Array[float]
var wheelPositions : Array[float]
var currSpeed : float = 0.0

func initialise(arg_wheelYOffsets : Array[float], arg_fixedOffset : float) -> void:
	var arrSize = arg_wheelYOffsets.size()
	wheelPoints = arrSize
	wheelPositions.resize(wheelPoints)
	wheelYOffsets.resize(wheelPoints) 
	for i in range(wheelPoints):
		wheelYOffsets[i] = curve.get_point_position(firstPointIdx + i).y - arg_wheelYOffsets[i]

func _process(delta):
	offset = wrapf(offset + currSpeed * delta, 0.0, distanceBetweenTrack)
	update_mesh(delta)

func update_mesh(delta):
	# Update one additional point before and after last wheel for smoother curving on the ends
	var newPos : Vector3
	newPos = curve.get_point_position(firstPointIdx-1)
	newPos.y = wheelPositions[0] + wheelYOffsets[0]
	curve.set_point_position(firstPointIdx-1, newPos)
	
	for i in range(wheelPoints):
		newPos = curve.get_point_position(i + firstPointIdx)
		newPos.y = wheelPositions[i] + wheelYOffsets[i]
		curve.set_point_position(i + firstPointIdx, newPos)

	newPos = curve.get_point_position(firstPointIdx + wheelPoints)
	newPos.y = wheelPositions[wheelPoints-1] + wheelYOffsets[wheelPoints-1]
	curve.set_point_position(firstPointIdx + wheelPoints, newPos)
	
	var path_length : float = curve.get_baked_length()
	var count = floor(path_length / distanceBetweenTrack)
	trackMM.instance_count = count
	linkMM.instance_count = count
	for i in range(count):
		var curveDistance = distanceBetweenTrack * i + offset
		var transform = curve.sample_baked_with_rotation(curveDistance)
		trackMM.set_instance_transform(i, transform)
		linkMM.set_instance_transform(i, transform)
	
func update_wheel_pos(wheelsPos : Array[float]) -> void:
	wheelPositions = wheelsPos
	
func update_speed(newSpeed : float) -> void:
	currSpeed = newSpeed
