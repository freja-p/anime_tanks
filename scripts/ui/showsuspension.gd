extends Control

var suspensions : Array
var labels : Array
# Called when the node enters the scene tree for the first time.
func _ready():
	labels = get_children()
	print(labels)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	suspensions = get_parent().get_node("Player").get_lengths()
	for i in range(4):
		labels[i].text =  str(suspensions[i])
