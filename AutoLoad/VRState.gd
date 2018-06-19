extends Node

#Emitted when the trigger button is pressed
signal trigger_pressed(controllerID)
#Emitted when the trigger button is released
signal trigger_released(controllerID)
#Emitted when the trigger axes change
signal trigger_axis(value, controllerID)

var controllerPointer = load("res://GameScenes/ControllerPointer/ControllerPointer.tscn")

var VRWorldScale = 10

var Controllers = {}
var ControllerData = {}

#menu id: 1
#grip id: 2
#touchpad press id: 14
#trigger id: 15
#Front-facing touchpad x-axis id: 0
#Front-facing touchpad y-axis id: 1
#Trigger axis id: 2

#Forward for controllers is -1*transform.basis.z

func _process(var delta):
	#Loop for each controller
	for _id in Controllers.keys():
		#Update axis data
		#Front-facing touchpad x-axis id: 0
		ControllerData[_id]["face_x_axis"] = Controllers[_id].get_joystick_axis(0)
		#Front-facing touchpad y-axis id: 1
		ControllerData[_id]["face_y_axis"] = Controllers[_id].get_joystick_axis(1)
		#Trigger axis id: 2
		ControllerData[_id]["trigger_axis"] = Controllers[_id].get_joystick_axis(2)
		
		#Grab the current transform
		ControllerData[_id]["transform"] = ControllerData[_id]["pointer"].global_transform
		
		#If the trigger axis is being held, emit signal
		if (ControllerData[_id]["trigger_axis"] > 0):
			emit_signal("trigger_axis", ControllerData[_id]["trigger_axis"], _id)
		

func add_controller(var controllerID, var controllerObj):
	#Add this controller to the dictionary (or replace the existing one)
	Controllers[controllerID] = controllerObj
	#Connect button signals
	if (!controllerObj.is_connected("button_pressed", VRState, "_on_controller_button_pressed")):
		controllerObj.connect("button_pressed", VRState, "_on_controller_button_pressed", [controllerID])
		controllerObj.connect("button_release", VRState, "_on_controller_button_released", [controllerID])
		
		#add pointer node
		var pointerInstance = controllerPointer.instance()
		pointerInstance.set_name("pointer")
		controllerObj.add_child(pointerInstance)
		#Give the pointer a controllerID
		pointerInstance.parentControllerID = controllerID
		#Properly place the pointer relative to the controller: 0, -0.015, -0.045
		pointerInstance.translation = Vector3(0.0, -0.15, -0.45)
		
		ControllerData[controllerID] = {
			"trigger_axis": 0,
			"face_x_axis": 0,
			"face_y_axis": 0,
			"pointer": pointerInstance,
			"transform": controllerObj.global_transform
		}
		
		print("Joystick with ID " + String(controllerObj.get_joystick_id()) + " connected.")


func _on_controller_button_pressed(var buttonID, var controllerID):
	match buttonID:
		1:
			#Menu Button
			print("menu button pressed")
		2:
			print("grip button pressed")
		14:
			#todo: face button logic
			print("face button pressed")
		15:
			#Trigger Button
			print("trigger button pressed")
			emit_signal("trigger_pressed", controllerID)
	
func _on_controller_button_released(var buttonID, var controllerID):
	match buttonID:
		1:
			#Menu Button
			print("menu button released")
		2:
			print("grip button released")
		14:
			#todo: face button logic
			print("face button released")
		15:
			#Trigger Button
			print("trigger button released")
			emit_signal("trigger_released", controllerID)
	