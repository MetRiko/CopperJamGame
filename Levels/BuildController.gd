extends Node2D

onready var tilemap = Game.tilemap
onready var level = Game.level
onready var gui = Game.gui

var entityData

func _ready():
	gui.connect("module_button_pressed", self, "build_object")

func build_object(moduleData):
	entityData = moduleData.moduleId
	if entityData != null:
		$Sprite.frame = moduleData.frameId if moduleData.frameId != null else 0
		$Sprite.visible = true

func _process(delta):
	if entityData != null:
		$Sprite.global_position = Vector2(tilemap.map_to_world(level.getCellIdxFromPos(get_global_mouse_position())))+Vector2(tilemap.cell_size/2)

func _unhandled_input(event):
	if event.is_action_pressed("LMB") && entityData != null:
		level.createEntity(entityData,level.getCellIdxFromPos(get_global_mouse_position()),false)
		entityData = null
	elif event.is_action_pressed("RMB") && entityData != null:
		entityData = null
	if event.is_action_pressed("LMB") && entityData == null:
		$Sprite.visible = false
	elif event.is_action_pressed("RMB") && entityData == null:
		$Sprite.visible = false
