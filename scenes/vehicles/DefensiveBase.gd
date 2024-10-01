extends Projectile

@export var activeDuration : float = 0.5

@onready var defenseBubble : Hitbox = $DefenceBubble
@onready var activeTimer : Timer = $ActiveTimer

func _ready():
	pass

func initialise(worldPos : Vector3, rot : Basis):
	global_position = worldPos
	global_transform.basis = rot
	defenseBubble.ownerEntity = shooter
