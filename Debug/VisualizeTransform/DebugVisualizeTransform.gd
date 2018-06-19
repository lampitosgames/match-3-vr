extends Spatial

var parent

func _ready():
	parent = get_parent()

func _process(delta):
	self.global_transform = parent.global_transform
