extends Area
#Enum to determine how this object responds to being grabbed and dragged
enum MoveType {FREE_MOVE, AXIS_CONSTRAINED, AXIS_DISTANCE_CONSTRAINED, SNAP}
export (MoveType) var activeMoveType

#Only bound to one controller at a time
var boundToID = -1
#Can collide with many controllers at once
var collidingWithIDs = []
#Position relative to the bound controller
var boundOffset = null
#Position the movable object was grabbed at
var startingPos = null

func _ready():
	#Bind controller trigger to self
	VRState.connect("trigger_pressed", self, "_on_grab")
	VRState.connect("trigger_released", self, "_on_release")
	
	#Connect area collisions. Mostly used for detecting collision with controller pointers
	self.connect("area_entered", self, "_on_area_entered")
	self.connect("area_exited", self, "_on_area_exited")


func _process(delta):
	if (VRState.ControllerData.has(boundToID)):
		match (activeMoveType):
			MoveType.FREE_MOVE:
				self.global_transform.origin = VRState.ControllerData[boundToID]["transform"].origin + boundOffset
			MoveType.AXIS_CONSTRAINED:
				var newDesiredPos = VRState.ControllerData[boundToID]["transform"].origin - startingPos + boundOffset
				self.global_transform.origin = startingPos + Utils.vector_max([Vector3(newDesiredPos.x, 0, 0), Vector3(0, newDesiredPos.y, 0), Vector3(0, 0, newDesiredPos.z)])

#Handler for controller trigger signal
func _on_grab(controllerID):
	#Remove active state from previous bound controller if it exists
	if (VRState.ControllerData.has(boundToID)):
		VRState.ControllerData[boundToID]["pointer"].remove_active_color()
	#Check if the controller overlaps this object
	if (collidingWithIDs.has(controllerID)):
		#Bind to the controller
		boundToID = controllerID
		#Store current position
		startingPos = global_transform.origin
		#Store relative position
		boundOffset = global_transform.origin - VRState.ControllerData[boundToID]["transform"].origin

func _on_release(controllerID):
	if (controllerID == boundToID):
		VRState.ControllerData[boundToID]["pointer"].remove_active_color()
		boundToID = -1

func _on_area_entered(otherArea):
	if (otherArea.get("parentControllerID")):
		collidingWithIDs.append(otherArea.parentControllerID)
		otherArea.set_active_color()

func _on_area_exited(otherArea):
	if (otherArea.get("parentControllerID")):
		collidingWithIDs.erase(otherArea.parentControllerID)
		if !(otherArea.parentControllerID == boundToID):
			otherArea.remove_active_color()