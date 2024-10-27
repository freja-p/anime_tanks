class_name Entity_Vehicle_Enemy
extends Entity

@export_category("Stats")
@export var baseStats : int
@export var maxHP : float = 100
var currHP : float = maxHP

@export_category("AI")
@export var abilitiesAvailable : Array[Ability]
var abilities : EntityAbilities
@export var patrolBehaviours : Array[AI_PatrolPathRegion_R]
@export var attackBehaviours : Array[int]
@export var repositionMinDistance : float = 10
@export var repositionMaxDistance : float = 50
@export var distanceFromAttackerMin : float = 0.0
@export var distanceFromAttackerMax : float = 1000

# AI
@onready var aiFSM : AIFSM = $AIFSM as AIFSM
@onready var navAgent : NavigationAgent3D = $Navigator as NavigationAgent3D
@onready var detector : EntityDetector = $Detector as EntityDetector
@onready var threatAnalyzer : ThreatAnalyzer = $ThreatAnalyzer as ThreatAnalyzer
@onready var aiVariables : AIVariableStore = AIVariableStore.new()

# Movement
@onready var vehicleBody : VehicleBody = $Body as VehicleBody
@onready var vehFSM : VehicleFSM = $VehicleControllerFSM as VehicleFSM
var vehFsmVars : Dictionary
var VEHVARS = VehicleState.VEHVARS
var grounded : bool = false

# Stats
@onready var spawnPosition : Vector3 = global_position

func initialise(arg_spawnLocation : Vector3):
	spawnPosition = arg_spawnLocation

func _ready():
	global_position = spawnPosition
	
	vehicleBody.initialise(self, vehicleStats)

	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = to_local(vehicleBody.centerVector)

	vehFsmVars = vehFSM.init(self)
	vehFSM.start_fsm()
	
	_init_aivars()
	aiFSM.init(self, navAgent, aiVariables, patrolBehaviours)
	aiFSM.start_fsm()

	abilities = EntityAbilities.new()
	for ability in abilitiesAvailable:
		var abilityNode = _init_ability(ability) as AbilityExecutor
		abilities.add_ability(abilityNode)
		
	aiVariables.ABILITIES = abilities
	
	detector.parentEntity = self
	threatAnalyzer.parentEntity = self

func _init_aivars():
	aiVariables.DETECTEDENTITIES = detector.detectedEntities
	
	aiVariables.REPOSITIONMOVEMIN = repositionMinDistance
	aiVariables.REPOSITIONMOVEMAX = repositionMaxDistance
	aiVariables.ATTACKERDISTANCEMIN = distanceFromAttackerMin
	aiVariables.ATTACKERDISTANCEMAX = distanceFromAttackerMax
	aiVariables.FACTION = faction
	
	aiVariables.new_target_position.connect(_on_ai_new_target_position)
	aiVariables.stop.connect(_on_ai_stop)
	
func _process(delta):
	if dying:
		return
		
	vehFSM.process_frame(delta)
	aiFSM.process_frame(delta)
	
	if not aiVariables._TURRETLOCK:
		if aiVariables._AIMBYANGLE:
			turretMesh.turn_to_rad(aiVariables._TURRETTARGET.y, aiVariables._TURRETTARGET.z)
		else:
			turretMesh.aim_at(aiVariables._TURRETTARGET)
		
	else:
		turretMesh.reset_turret()
		
	$TurretHitbox.global_rotation = turretMesh.global_rotation

func _physics_process(delta):
	if dying:
		return
	if not navAgent.is_navigation_finished():
		vehFsmVars[VehicleState.VEHVARS.CURRENTTARGET] = navAgent.get_next_path_position()
	vehFSM.process_physics(delta)
	grounded = vehicleBody.update_suspension(self, delta, Quaternion(transform.basis))

	vehFsmVars[VehicleState.VEHVARS.GROUNDED] = grounded
	vehicleBody.update_wheel_speed(self)

func alert(entity : Entity) -> void:
	aiVariables.ALERT_ = true
	aiVariables.LASTSEENPOSITION = entity.global_position
	
func get_target_point() -> Vector3:
	return turretMesh.get_aiming_position()
	
func _get_highest_threat() -> Entity:
	return threatAnalyzer.get_highestThreat()

func _on_ai_new_target_position(newPosition : Vector3):
	vehFsmVars[VehicleState.VEHVARS.NEWTARGET] = true
	navAgent.target_position = newPosition
	
func _on_navigator_path_changed():
	var finalPos = navAgent.get_final_position()
	vehFsmVars[VehicleState.VEHVARS.FINALTARGET] = finalPos
	aiVariables._FINALTARGET = finalPos

func _on_navigator_target_reached():
	vehFsmVars[VehicleState.VEHVARS.TARGETREACHED] = true
	aiVariables.TARGETREACHED_ = true
	
func _on_ai_stop():
	vehFsmVars[VehicleState.VEHVARS.STOP_] = true
	
func hit(hitbox : Hitbox, base_damage : float, shooter : Entity) -> void:
	var damage = base_damage
	if hitbox.name == "TurretHitbox":
		damage *= 1.3
	
	currHP -= damage
	if currHP <= 0:
		die(shooter)
	
	threatAnalyzer.hit_by(shooter, damage)
	detector.hit_by(shooter, damage)
	aiVariables.ALERT_ = true
	aiVariables.LASTSEENPOSITION = shooter.global_position

func die(shooter : Entity):
	return
	dying = true
#	$CollisionBox.scale_object_local(Vector3(1, 0.5,1))
	turretMesh.reparent(get_parent())
	turretMesh.translate_object_local(Vector3(0,0.2,0))
	turretMesh.die()
	died.emit(self, shooter)
	$DeathTimer.start()

func _on_death_timer_timeout():
	turretMesh.queue_free()
	aiVariables.free()
	queue_free()

func _on_threat_analyzer_threat_target_changed():
	aiVariables.HIGHESTTHREATENTITY = threatAnalyzer.get_highestThreat()
	aiVariables.ALERT_ = true

func _on_event_bus_turret_target_reach():
	aiVariables.AIMINGATTARGET = true

func _on_event_bus_aiming_at_entity_state_changed(isAiming, entity):
	aiVariables.AIMINGATENTITY = isAiming
	aiVariables.LOOKINGATENTITY = entity
