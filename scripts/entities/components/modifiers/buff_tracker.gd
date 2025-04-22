class_name BuffTracker
extends Node
## Entity Component for tracking active buffs
## 
## Collects and maintains the list of active [BuffStatus]s on an [Entity]
## This component is the first object that will receive any buffs applied to it 
## from any source

class BuffStatus:
	var timer : Timer
	var stacks : int

signal buff_added(buff : BuffData, count : int)
signal buff_removed(buff : BuffData, count : int)

@export var owner_entity : Entity

var _buffs : Dictionary[BuffData, BuffStatus]


func get_buffstatus(buff_data : BuffData) -> BuffStatus:
	if _buffs.has(buff_data):
		return _buffs[buff_data]
	return null


func add_buff(new_buff : BuffData, count : int = 1) -> void:
	var buff_status : BuffStatus = get_buffstatus(new_buff)
	var stacks_added : int
	
	if buff_status:
		if new_buff.has_duration:
			buff_status.timer.start()
		
		if buff_status.stacks >= new_buff.max_stacks:
			return
		else:
			if buff_status.stacks + count < new_buff.max_stacks:
				stacks_added = count
			else:
				stacks_added = new_buff.max_stacks - buff_status.stacks
				
			buff_status.stacks = stacks_added
			
			
	else:
		buff_status = BuffStatus.new()
		_buffs[new_buff] = buff_status
		
		if new_buff.has_duration:
			buff_status.timer = _create_timer(new_buff)
			
		if count < new_buff.max_stacks:
			stacks_added = count
		else:
			stacks_added = new_buff.max_stacks
		
		
	print("%s added %d stacks of buff %s" % [owner_entity, stacks_added, new_buff.buff_name])
	buff_added.emit(new_buff, stacks_added)


func remove_buff(buff_to_remove : BuffData, count : int = 1) -> void:
	if buff_to_remove not in _buffs:
		print("BuffData to remove [%s] not found" % buff_to_remove.buff_name)
		return
	var stacks_to_remove : int
	var buff_status : BuffStatus = _buffs[buff_to_remove]
	
	if count < buff_status.stacks:
		stacks_to_remove = count
	else:
		stacks_to_remove = buff_status.stacks
		
	_buffs[buff_to_remove].stacks -= stacks_to_remove
	
	if _buffs[buff_to_remove].stacks <= 0:
		_buffs.erase(buff_to_remove)
		print("%s removed buff %s" % [owner_entity, buff_to_remove.buff_name])
	else:
		print("%s reduced buff stack %s by 1" % [owner_entity,buff_to_remove.buff_name] )
	
	buff_removed.emit(buff_to_remove, stacks_to_remove)


func _create_timer(buff_data : BuffData) -> Timer:
	var timer : Timer = Timer.new()

	timer.name = buff_data.buff_name
	timer.timeout.connect(_on_buff_timeout.bind(buff_data))
	add_child(timer)
	
	timer.start(buff_data.duration)

	return timer


func _on_buff_timeout(buff_data : BuffData):
	remove_buff(buff_data, buff_data.max_stacks)
	
