extends Node2D

onready var level = Game.level
onready var gui = Game.gui

var entityData

func _ready():
	gui.connect("module_button_pressed", self, "build_object")


func build_object(moduleData):
	entityData = moduleData.moduleId
	

func _unhandled_input(event):
	if event.is_action_pressed("LMB") && entityData != null:
		level.createEntity(entityData,level.getCellIdxFromPos(get_global_mouse_position()),false)
		entityData = null
	elif event.is_action_pressed("RMB") && entityData != null:
		entityData = null
