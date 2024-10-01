extends Label
var player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var v : Vector3 = player.linear_velocity
	var dir : Vector3 = v.slide(Vector3.UP)
	text = """
	Propulsion Velocity: %.3f
	Angle: %3f
	""" % [v.length(), rad_to_deg(dir.signed_angle_to(Vector3.FORWARD, Vector3.UP))]	
