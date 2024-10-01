extends AIState

@export_category("State Transitions")
@export var patrol_state : AIState
@export var attack_state : AIState
@export var investigate_state : AIState

@export_category("Component References")
@export var entityEventBus : EntityEventBus

@onready var reposition_timer = $RepositionTimer
@onready var attack_timer = $AttackTimer

var exitCombatFlag : bool
var readyToFire : bool

func setup():
	pass

func enter():
	super()
	readyToFire = false
	varStore._TURRETLOCK = false
	varStore._AIMBYANGLE = false
	varStore.TARGETREACHED_ = true
	exitCombatFlag = false
	
func exit():
	super()
	varStore._TURRETLOCK = true

func process_frame(delta):
	if exitCombatFlag:
		return patrol_state
		
	var targetEntity : Entity = parentEntity._get_highest_threat()
	
	if targetEntity:
		varStore._TURRETTARGET = targetEntity.global_position
		varStore.LASTSEENPOSITION = targetEntity.global_position
	else:
#		print("No target found")
		return investigate_state

	if varStore.TARGETREACHED_:
		varStore.TARGETREACHED_ = false
	
	elif reposition_timer.is_stopped() and\
		varStore.AIMINGATENTITY and\
		not parentEntity.faction.is_allied_to(varStore.LOOKINGATENTITY.faction):
		
		if not readyToFire and attack_timer.is_stopped():
			attack_timer.start()
			
		elif readyToFire and varStore.ABILITIES.has_ready_abilities():
			var pickedAbility : AbilityExecutor = varStore.ABILITIES.pick_random_ready()
			pickedAbility.target = varStore._TURRETTARGET
			pickedAbility.activate()
			readyToFire = false
			
			reposition_timer.start(varStore.REPOSITIONTIME)

	return null

func find_closest_target() -> Entity:
	var validEntities : Array[EntityDetectInfo] = []
	for entityName in varStore.DETECTEDENTITIES:
		var entityInfo : EntityDetectInfo = varStore.DETECTEDENTITIES[entityName]
	
		if entityInfo.isOccluded or varStore.FACTION.is_allied_to(entityInfo.trackedEntity.faction):
			continue
		
		validEntities.append(entityInfo)
	
	if validEntities.size() == 0:
		return null
	
	var closestEntity : Entity = validEntities[0].trackedEntity
	var closestDistance : float = parentEntity.global_position.distance_to(closestEntity.global_position) 
	for entityInfo in validEntities:
		var thisEntityDistance : float = parentEntity.global_position.distance_to(entityInfo.trackedEntity.global_position)
		if thisEntityDistance <  closestDistance:
			closestEntity = entityInfo.trackedEntity
			closestDistance = thisEntityDistance

	return closestEntity

func combat_reposition() -> void:
	var newPoint : Vector3
	var maxRetries = 20
	while true:
		if maxRetries < 0:
			break
		newPoint = select_new_position()
		maxRetries -= 1
		if newPoint.distance_to(varStore._TURRETTARGET) < varStore.ATTACKERDISTANCEMIN:
			continue
		elif newPoint.distance_to(varStore._TURRETTARGET) > varStore.ATTACKERDISTANCEMAX:
			continue
		break
		
#	varStore._FINALTARGET = newPoint
	varStore.new_target_position.emit(newPoint)
	return

func select_new_position() -> Vector3:
	var newPoint : Vector3 = parentEntity.global_position
	var randRadius : float = (varStore.REPOSITIONMOVEMAX - varStore.REPOSITIONMOVEMIN) * sqrt(randf()) + varStore.REPOSITIONMOVEMIN
	var randAngle : float = randf() * 2 * PI
	
	newPoint.x = newPoint.x + randRadius * cos(randAngle)
	newPoint.z = newPoint.z + randRadius * sin(randAngle)
	
	return newPoint

func _on_reposition_timer_timeout():
	combat_reposition()

func _on_turret_aiming_at_entity(aiming : bool, entity : Entity):
	pass

func _on_attack_timer_timeout():
	readyToFire = true
