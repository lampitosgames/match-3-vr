extends Node
#Imports
var baseGemScene = preload("res://GameScenes/Gems/BaseGem/BaseGem.tscn")

#Define the size of the board
export(int) var xSize = 6
export(int) var ySize = 6
export(int) var zSize = 6

#Distance between gem origins
export(float) var gridOffset = 2.0

var gameBoard = {}

func _ready():
	#Construct the board
	for xi in range(xSize):
		for yi in range(ySize):
			for zi in range(zSize):
				#Create a gem at this location
				_create_gem(xi, yi, zi, baseGemScene)

func _create_gem(_xi, _yi, _zi, _toInstance):
	var newGem = _toInstance.instance()
	gameBoard[Vector3(_xi, _yi, _zi)] = newGem
	newGem.translate_object_local(Vector3(_xi * gridOffset, _yi * gridOffset, _zi * gridOffset))
	newGem.activeMoveType = 2
	newGem.gridSnap = true
	newGem.gridSize = gridOffset
	add_child(newGem)
