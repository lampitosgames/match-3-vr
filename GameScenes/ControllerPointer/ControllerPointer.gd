extends Area

var defaultMat = null
var activeMat = load("res://GameScenes/ControllerPointer/PointerMaterialActive.tres")

export (int) var parentControllerID = null

func _ready():
	defaultMat = $SpherePointer.get_surface_material(0)

func set_active_color():
	$SpherePointer.set_material_override(activeMat)

func remove_active_color():
	$SpherePointer.set_material_override(defaultMat)