class_name ThreatAnalyzer
extends Node

class EntityThreatInfo:
	var name : String
	var entity : Entity
	var killCount : int = 0
	var damageDealt : float = 0.0
	var ally : bool = false
	
signal threat_target_changed(entity : Entity)

@export var detector : EntityDetector 
@export var health_manager : HealthManager
@export var hitboxes : Array[Hitbox]

var aiVars : AIVariableStore
var parentEntity : Entity

var threatLog : Dictionary
var highestThreat : EntityThreatInfo

var debug : bool = false

@onready var visibleEntities : Dictionary
@onready var detectedAllies : Dictionary

func _ready() -> void:
	for hitbox in hitboxes:
		hitbox.hit_by.connect(hit_by)
		
	parentEntity = get_parent()
	
	
func get_highestThreat() -> Entity:
	if highestThreat:
		if not highestThreat.entity or highestThreat.entity.dying:
			_refresh_threat()
			if not highestThreat:
				return null
		
		return highestThreat.entity
	else:
		return null


func hit_by(entity : Entity, damage : float):
	if parentEntity.faction.is_allied_to(entity.faction):
		return
	if not entity.name in threatLog:
		var newThreatInfo : EntityThreatInfo = EntityThreatInfo.new()
		newThreatInfo.entity = entity
		threatLog[entity.name] = newThreatInfo
		
	var threatInfo : EntityThreatInfo = threatLog[entity.name]
	threatInfo.name = entity.name
	threatInfo.damageDealt += damage
	_update_threat(threatInfo)
	
	
func _update_threat(newThreat : EntityThreatInfo) -> void:
#	if not newThreat.entity.name in visibleEntities:
#		print("%s early return when updating threat for %s " % [parentEntity.name, newThreat.entity.name])
#		print("%s new threat: %s" % [parentEntity.name, highestThreat.entity.name])
#		return
	if highestThreat and highestThreat.entity:
		if newThreat.damageDealt > highestThreat.damageDealt or newThreat.killCount > highestThreat.killCount:
			highestThreat = newThreat
			threat_target_changed.emit(highestThreat.entity)
		if debug: print("%s new threat: %s" % [parentEntity.name, highestThreat.entity.name])
		return
	
	highestThreat = newThreat
	var markForDelete : Array[String]
	for entityName in visibleEntities:
		if not visibleEntities[entityName]:
			markForDelete.append(entityName)
		elif threatLog[entityName].damageDealt > highestThreat.damageDealt:
			highestThreat = threatLog[entityName]
	for entityName in markForDelete:
		visibleEntities.erase(entityName)
		threatLog.erase(entityName)
	if debug: print("%s updated new threat: %s" % [parentEntity.name, highestThreat.entity.name])
	threat_target_changed.emit(highestThreat.entity)


func _refresh_threat() -> void:
	if visibleEntities.size() <= 0:
		highestThreat = null
		threat_target_changed.emit(highestThreat.entity)
		return
	
	var newThreat : bool = false
	highestThreat = threatLog[visibleEntities.keys()[0]]
	for entityName in visibleEntities:
		if threatLog[entityName].damageDealt > highestThreat.damageDealt:
			highestThreat = threatLog[entityName]
			newThreat = true	
	if newThreat:
		if debug: print("%s refreshed new threat: %s" % [parentEntity.name, highestThreat.entity.name])
		threat_target_changed.emit(highestThreat.entity)


func _on_detector_entity_died(entity : Entity, killer : Entity):
	if entity.name in threatLog:
		if debug: print("%s removed %s from threatLog" % [parentEntity.name, entity.name])
		threatLog.erase(entity.name)
#	if parentEntity.faction.is_allied_to(entity.faction):
#		return
	if not killer.name in threatLog:
		var threatInfo : EntityThreatInfo = EntityThreatInfo.new()
		threatInfo.entity = killer
		threatInfo.ally = parentEntity.faction.is_allied_to(killer.faction)
		threatLog[killer.name] = threatInfo
	var threatInfo : EntityThreatInfo = threatLog[killer.name] as EntityThreatInfo
	threatInfo.name = killer.name
	threatInfo.killCount += 1
	if not threatInfo.ally:
		if debug: print("%s updating threats with %s" % [parentEntity.name, killer.name])
		_update_threat(threatInfo)
	elif not highestThreat or entity.name == highestThreat.entity.name:
		if debug: print("%s refreshing threats" % [parentEntity.name])
		_refresh_threat()


func _on_detector_visible_entities_removed(entity : Entity):
	if entity.name == highestThreat.entity.name:
		highestThreat = null
		if visibleEntities.size() <= 0:
			highestThreat = null
			return
		_update_threat(threatLog[visibleEntities[visibleEntities.keys()[0]].name])
		
		
func _on_detector_visible_entities_added(entity : Entity):
	if not entity.name in threatLog:
		var newThreat : EntityThreatInfo = EntityThreatInfo.new()
		newThreat.entity = entity
		threatLog[entity.name] = newThreat
	var threatInfo : EntityThreatInfo = threatLog[entity.name]
	threatInfo.name = entity.name
	_update_threat(threatInfo)
