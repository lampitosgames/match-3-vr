extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	var interface = ARVRServer.find_interface("OpenVR")
	if (interface && interface.initialize()):
		get_viewport().arvr = true
		get_viewport().hdr = false
		
		VRState.connect("trigger_axis", self, "_on_controller_trigger")
		
		#Get controllers when they are ready
		$OVRFirstPerson/Left_Hand.connect("controller_activated", self, "_on_controller_activated")
		$OVRFirstPerson/Right_Hand.connect("controller_activated", self, "_on_controller_activated")

func _on_controller_trigger(var _value, var _controllerID):
#	if !(_value < 0.01):
#		VRState.Controllers[_controllerID].rumble = _value
#	else:
#		VRState.Controllers[_controllerID].rumble = 0.0
	pass

func _on_controller_activated(var controllerObj):
	print("Controller activated: " + String(controllerObj.controller_id))
	VRState.add_controller(controllerObj.controller_id, controllerObj)
