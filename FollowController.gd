extends MeshInstance

var boundToID = -1;

func _ready():
	#Bind trigger to self
	VRState.connect("trigger_pressed", self, "_on_grab")
	VRState.connect("trigger_released", self, "_on_release")

#Demo script for snapping an object to the controller's transform
func _process(delta):
	if (VRState.ControllerData.has(boundToID)):
		self.global_transform.origin = VRState.ControllerData[boundToID]["transform"].origin
		
func _on_grab(controllerID):
	boundToID = controllerID

func _on_release(controllerID):
	if (controllerID == boundToID):
		boundToID = -1