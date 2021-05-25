extends Node2D

onready var level = Game.level

onready var pic = level.getPlayerInputController()

const CURSORS = {
	BOOTS = 0,
	PLUS = 1,
	RED_CIRCLE =  2,
	WRENCH = 3,
	ARROW = 9,
	TARGET = 10,
	COG = 11,
	STOP = 12,
}

var latestModuleToAttach = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pic.connect("hovered_object_changed", self, "onHoveredObjectChanged")
	pic.connect("module_to_attach_changed", self, "onModuleToAttachChanged")
	pic.connect("state_changed", self, "onStateChanged")
	
	changeCursor(CURSORS.ARROW)

func _process(delta):
	global_position = get_global_mouse_position()

func changeCursor(frameId):
	$Sprite.frame = frameId

func onModuleToAttachChanged(moduleId, rot):
	latestModuleToAttach = moduleId
#	$Sprite.visible = moduleId == null

func onStateChanged(state):
	_updateCursor(pic.getHoveredObject())

func onHoveredObjectChanged(hoveredObject):
	_updateCursor(hoveredObject)

func _updateCursor(hoveredObject):
	if pic.isNormalState():
		# on module - use
		if hoveredObject == pic.HOVERED_MODULE:
			changeCursor(CURSORS.ARROW)
		# on enemy - target
		elif hoveredObject == pic.HOVERED_ENEMY:
			changeCursor(CURSORS.TARGET)
		# on floor - boots
		elif hoveredObject == pic.HOVERED_JUST_FLOOR:
			changeCursor(CURSORS.BOOTS)
		# on obstacle - cursor
		elif hoveredObject == pic.HOVERED_OBSTACLE:
			changeCursor(CURSORS.STOP)

	elif pic.isBuildingState():
		# on module - program
		if hoveredObject == pic.HOVERED_MODULE:
			changeCursor(CURSORS.WRENCH)
		# on enemy - stop
		elif hoveredObject == pic.HOVERED_ENEMY:
			changeCursor(CURSORS.STOP)
		# on floor - new machine
		elif hoveredObject == pic.HOVERED_JUST_FLOOR:
			changeCursor(CURSORS.PLUS)
		# on obstacle - stop
		elif hoveredObject == pic.HOVERED_OBSTACLE:
			changeCursor(CURSORS.STOP)
