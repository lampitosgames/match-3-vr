extends Area
#TODO: Add signals for pickup actions
#TODO: Add haptic feedback to UI

#Enum to determine how this object responds to being grabbed and dragged
enum MoveType {FREE_MOVE = 0, SINGLE_AXIS_CONSTRAINED = 1, COORDINATE_AXIS_CONSTRAINED = 2}
export (MoveType) var activeMoveType = MoveType.FREE_MOVE
#Constraint for single-axis movement
export(Vector3) var singleAxisConstraint = Vector3(1.0, 0.0, 0.0)
#Transform for constraining movement to coordinate axes.  Scale factor should be 1.0
export(Basis) var coordAxisConstraint = Basis()

#Grid snapping
export(bool) var gridSnap = false
export(float) var gridSize = 1.0

#Maximum displacement (0 for none)
export (float) var maxDisplacement = 0

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
	
	coordAxisConstraint = self.transform.basis
	
	#Connect area collisions. Mostly used for detecting collision with controller pointers
	self.connect("area_entered", self, "_on_area_entered")
	self.connect("area_exited", self, "_on_area_exited")


func _process(delta):
	if (VRState.ControllerData.has(boundToID)):
		var newDesiredPos = VRState.ControllerData[boundToID]["transform"].origin - startingPos + boundOffset
		var calculatedMove = null
		match (activeMoveType):
			MoveType.FREE_MOVE:
				if (!gridSnap):
					#Simply translate to the controller's position
					calculatedMove = newDesiredPos
				else:
					#This is a little tricky. Essentially, snap to the closest grid point on global axes, then rotate into local coordinates
					#In order for the controller to line up though, we have to apply an inverse rotation to the calculated controller position so that 
					#when the coordinates are rotated back, the visualized position remains in world coordinates
					calculatedMove = coordAxisConstraint.inverse() * newDesiredPos
					calculatedMove = coordAxisConstraint * Utils.vector_snap(calculatedMove, Vector3(gridSize, gridSize, gridSize))
			MoveType.SINGLE_AXIS_CONSTRAINED:
				#Project newDesiredPos onto the axis of constraint
				calculatedMove = Utils.vector_proj(newDesiredPos, singleAxisConstraint)
				#If grid snapping is on, clamp to nearest snap point
				if (gridSnap):
					#Scale the constraining axis to the grid size
					var snapFactor = singleAxisConstraint.normalized() * gridSize
					#Snap calculated move by the snap vector
					calculatedMove = Utils.vector_snap(calculatedMove, snapFactor)
			MoveType.COORDINATE_AXIS_CONSTRAINED:
				#Project the controller position onto each local axis.  Use the largest resulting vector for the new position
				calculatedMove = Utils.vector_max([Utils.vector_proj(newDesiredPos, coordAxisConstraint.x), 
												   Utils.vector_proj(newDesiredPos, coordAxisConstraint.y),
												   Utils.vector_proj(newDesiredPos, coordAxisConstraint.z)])
				#If grid snap is active, round the calculated move's length to the nearest snap point
				if (gridSnap):
					calculatedMove = calculatedMove.normalized() * stepify(calculatedMove.length(), gridSize)
		#Constrain displacement?
		if (maxDisplacement > 0):
			#If the calculated move is larger than the maximum displacement, clamp to maximum displacement
			calculatedMove = Utils.vector_clamp(calculatedMove, maxDisplacement)
		#Finally, move the object
		self.transform.origin = startingPos + calculatedMove

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
		startingPos = transform.origin
		#Store relative position
		boundOffset = transform.origin - VRState.ControllerData[boundToID]["transform"].origin

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