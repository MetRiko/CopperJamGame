extends Node2D

signal hovered_object_changed

onready var level = Game.level

enum {
	HOVERED_OBSTACLE,
	HOVERED_MODULE,
	HOVERED_ENEMY,
	HOVERED_JUST_FLOOR,
}

var hoveredObject = HOVERED_JUST_FLOOR

var currentMouseIdx = Vector2(-100, -100)

var latestHoveredModule = null
var selectedModule = null

var latestNewMachine = null

# Getters

func getMouseIdx():
	return currentMouseIdx

func getHoveredMachine():
	if latestHoveredModule != null and is_instance_valid(latestHoveredModule):
		var machine = latestHoveredModule.getMachine()
		if is_instance_valid(machine):
			return machine
	return null

func getHoveredModule():
	return latestHoveredModule

# Core

func _ready():
	Game.beatController.connect("after_beat", self, "onAfterBeat")

func _process(delta):
	var mouseIdx = level.getCellIdxFromMousePos()
	if mouseIdx != currentMouseIdx:
		currentMouseIdx = mouseIdx
		_hoverObject(mouseIdx)

func onAfterBeat():
	var mouseIdx = level.getCellIdxFromMousePos()
	_hoverObject(mouseIdx)

func _hoverObject(idx):

	var isObstacle = level.isObstacle(idx)
	if isObstacle:
		_hoverObstacle()
		emit_signal("hovered_object_changed", hoveredObject)
		return
	
	var machine = level.getMachineFromIdx(idx)
	if machine != null:
		_hoverModule(machine.getModuleFromLocalIdx(machine.convertToLocalIdx(idx)))
		emit_signal("hovered_object_changed", hoveredObject)
		return
	else:
		_unhoverLatestModule()

	var isEnemy = level.getEntityFromIdx(idx) != null
	if isEnemy:
		_hoverEnemy()
		emit_signal("hovered_object_changed", hoveredObject)
		return
	
	_hoverFloor()

	emit_signal("hovered_object_changed", hoveredObject)

############### Hovering

func getHoveredObject():
	return hoveredObject

func isHoveredObstacle():
	return hoveredObject == HOVERED_OBSTACLE

func isHoveredModule():
	return hoveredObject == HOVERED_MODULE

func isHoveredEnemy():
	return hoveredObject == HOVERED_ENEMY

func isHoveredFloor():
	return hoveredObject == HOVERED_JUST_FLOOR

func _unhoverLatestModule():
	_hoverModule(null)

func _hoverObstacle():
	hoveredObject = HOVERED_OBSTACLE

func _hoverModule(module):
	hoveredObject = HOVERED_MODULE

	if module != latestHoveredModule:

		if latestHoveredModule != null and is_instance_valid(latestHoveredModule):
			if latestHoveredModule != selectedModule:
				latestHoveredModule.modulate = Color(1.0, 1.0, 1.0, 1.0)

#			if (module != null and latestHoveredModule.getMachine() != module.getMachine()) or module == null:
#				latestHoveredModule.getMachine().setOutline(0.0)

	if module != null and module != selectedModule:
#		module.getMachine().setOutline(1.0, Color(1.0, 1.0, 1.0, 0.6))
		module.modulate = Color(1.2, 1.2, 1.2, 1.0)

	latestHoveredModule = module

func _hoverEnemy():
	hoveredObject = HOVERED_ENEMY

func _hoverFloor():
	hoveredObject = HOVERED_JUST_FLOOR
