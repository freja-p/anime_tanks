class_name Faction
extends Resource

@export var factionName : String
@export var alliedFactions : Array[Faction]

func is_allied_to(faction : Faction) -> bool:
	return faction == self or alliedFactions.has(faction)
