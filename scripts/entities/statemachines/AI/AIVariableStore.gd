class_name AIVariableStore
extends RefCounted

# AIVariableStore is used to pass data into and out of the AI FSM
# or between states that need to share data
# _VARs can be written to only by AIState nodes
# VARs can be written to only by external nodes
# VAR_s are triggers that external nodes sets and states reset

var NAVIGATOR : NavigationAgent3D
var FACTION : Faction

# Turret aiming
var _TURRETTARGET : Vector3
var _TURRETLOCK : bool = true
var AIMINGATENTITY : bool = false
var AIMINGATTARGET : bool = false
var LOOKINGATENTITY : Entity
var _AIMBYANGLE : bool = false

# Patrol AI
var GLOBALPOSITION : Vector3
var PATROLBEHAVIOURS : Array[AI_PatrolPathRegion_R]
var CURRENTBEHAVIOUR : AI_PatrolPathRegion_R
var _FINALTARGET : Vector3
var TARGETREACHED_: bool
signal new_target_position(newPosition : Vector3)
signal stop

# Attack AI
var DETECTEDENTITIES : Dictionary
var HIGHESTTHREATENTITY : Entity
var LASTSEENPOSITION : Vector3
var ALERT_ : bool
var ATTACKERDISTANCEMIN : float = 0
var ATTACKERDISTANCEMAX : float = INF
var REPOSITIONMOVEMIN : float = 10
var REPOSITIONMOVEMAX : float = 30
var REPOSITIONTIME : float = 1
var ABILITIES : EntityAbilities

# Investigate AI
var INVESTIGATERADIUS : float = 15
var EXITCOMBATTIME : float = 30
	
