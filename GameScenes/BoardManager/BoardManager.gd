extends Node

#Define the size of the board
export(int) var xSize = 6
export(int) var ySize = 6
export(int) var zSize = 6

var gameBoard = {}

func _ready():
	#Construct the board
	for xi in range(xSize):
		for yi in range(ySize):
			for zi in range(zSize):
				#Create an entry at this location
				gameBoard[Vector3(xi, yi, zi)] = null
