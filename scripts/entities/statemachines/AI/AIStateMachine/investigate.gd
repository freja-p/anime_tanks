extends AIState

@export var patrol_state : AIState
@export var attack_state : AIState
@onready var combat_timeout = %CombatTimeout

var exitCombat : bool

func enter():
	super()
#	print("Investigate %s" % parentEntity.name)
#	varStore._FINALTARGET = varStore.LASTSEENPOSITION
	varStore.new_target_position.emit(varStore.LASTSEENPOSITION)
	combat_timeout.start(varStore.EXITCOMBATTIME)
	exitCombat = false
	
func exit():
	super()

func process_frame(delta):
	varStore.HIGHESTTHREATENTITY = parentEntity._get_highest_threat()
	if varStore.HIGHESTTHREATENTITY or varStore.ALERT_:
		varStore.ALERT_ = false
		varStore.stop.emit()
#		print("Attack %s" % parentEntity.name)
		return attack_state
	elif exitCombat:
#		print("Patrol")
		return patrol_state
		
	if varStore.TARGETREACHED_:
		varStore.TARGETREACHED_ = false
#		varStore._FINALTARGET = select_point_in_radius(varStore.LASTSEENPOSITION, varStore.INVESTIGATERADIUS)
		
		varStore.new_target_position.emit(select_point_in_radius(varStore.LASTSEENPOSITION, varStore.INVESTIGATERADIUS))

func _on_combat_timeout_timeout():
	exitCombat = true
