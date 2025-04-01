class_name Modifier
extends RefCounted

var modifier_resource : ModifierData
var stacks : int = 1
var modifier_timer : Timer = null
var modifier_handler : ModifierHandler = null


# WARNING: Need to redo this constructor, as Godot should not have args without defaults in _init()
func _init(arg_modifier_resource : ModifierData, arg_modifier_handler : ModifierHandler):
	modifier_resource = arg_modifier_resource
	modifier_handler = arg_modifier_handler
	if modifier_resource and modifier_resource.context.has_duration:
		modifier_timer = modifier_handler._create_timer(modifier_resource.context)
		modifier_timer.timeout.connect( func() : modifier_handler.remove_modifier(modifier_resource))


# Returns true if stack counter was increased
func add_stack() -> bool:
	var stack_incremented : bool
	if stacks >= modifier_resource.max_stacks:
		stack_incremented = false
	else:
		stacks += 1
		stack_incremented = true
	
	if modifier_resource.context.has_duration:
		modifier_timer.stop()
		modifier_timer.start(modifier_resource.context.duration)
	return stack_incremented
	
	
func remove_stack() -> bool:
	stacks -= 1
	if stacks <= 0:
		if modifier_timer:
			modifier_timer.queue_free()
		return true
	return false
