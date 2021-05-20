extends Node2D

onready var tilemap = Game.tilemap
onready var level = Game.level
onready var gui = Game.gui

var inBuildMode := false

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
	if inBuildMode == true: 
		update()

func _unhandled_input(event):
	if inBuildMode == true:
		if event.is_action_pressed("LMB"):
			show_gui()
			build_mode()
	if inBuildMode == true:
		if event.is_action_pressed("RMB"):
			inBuildMode = false
	if event.is_action_pressed("LMB") && entityData != null:
		level.createEntity(entityData,level.getCellIdxFromPos(get_global_mouse_position()),false)
		entityData = null
	elif event.is_action_pressed("RMB") && entityData != null:
		entityData = null
	if event.is_action_pressed("LMB") && entityData == null:
		$Sprite.visible = false
	elif event.is_action_pressed("RMB") && entityData == null:
		$Sprite.visible = false

func _draw():
	if inBuildMode == true:
		var pos = Vector2(tilemap.map_to_world(level.getCellIdxFromPos(get_global_mouse_position()) - Vector2(1,1)))+Vector2(tilemap.cell_size)
		draw_rect(Rect2(pos,Vector2(32,32)),Color(0,255,0,0.2),false, 1.0,false)
	#if inBuildMode == false:
	#	draw_rect(Rect2(Vector2(0,0),Vector2(32,32)),Color(0,255,0,0),false, 1.0,false)
	
func hide_gui():
	gui.get_node("Control").set_visible(false)

func show_gui():
	gui.get_node("Control").set_visible(true)

func build_mode():
	#if  = level.getCellIdxFromMousePos():
	pass
