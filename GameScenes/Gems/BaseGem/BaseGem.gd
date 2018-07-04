extends "res://GameScenes/MovableObject/MovableObject.gd"

func _on_grab(controllerID):
	#need to call parent method for overridden signal function
	._on_grab(controllerID)

func _on_release(controllerID):
	#need to call parent method for overridden signal function
	._on_release(controllerID)