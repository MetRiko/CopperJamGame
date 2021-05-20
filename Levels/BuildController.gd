extends Node2D

onready var tilemap = Game.tilemap
onready var level = Game.level
onready var gui = Game.gui

var state := int(0)
var currentEditingMachine = null

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
		pass#$Sprite.global_position = Vector2(tilemap.map_to_world(level.getCellIdxFromPos(get_global_mouse_position())))+Vector2(tilemap.cell_size/2)
	update()

func _unhandled_input(event):

	if state == 1:
		if event.is_action_pressed("LMB"): #state 2 attach module
			show_gui()
			machine_mode()
			state = 2
	elif state == 1:
		if event.is_action_pressed("RMB"):
			state = 0

	elif state == 2:
		if event.is_action_pressed("LMB"):
			var mouseIdx = currentEditingMachine.getLocalMouseIdx()
			if entityData != null:
				currentEditingMachine.attachModule(entityData, mouseIdx)
			else:
				 push_error("jestes glupi af")
		if event.is_action_pressed("RMB"):
			var mouseIdx = currentEditingMachine.getLocalMouseIdx()
			currentEditingMachine.detachModule(mouseIdx)

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
	if state == 0:
		var pos = Vector2(tilemap.map_to_world(level.getCellIdxFromPos(get_global_mouse_position()) - Vector2(1,1)))+Vector2(tilemap.cell_size)
		draw_rect(Rect2(pos,Vector2(32,32)),Color(0,255,0,0.2),false, 1.0,false)
	if state == 1:
		var pos = Vector2(tilemap.map_to_world(level.getCellIdxFromPos(get_global_mouse_position()) - Vector2(1,1)))+Vector2(tilemap.cell_size)
		draw_rect(Rect2(pos,Vector2(32,32)),Color(0,0,255,0.2),false, 1.0,false)
	if state == 2:
		var pos = Vector2(tilemap.map_to_world(level.getCellIdxFromPos(get_global_mouse_position()) - Vector2(1,1)))+Vector2(tilemap.cell_size)
		draw_rect(Rect2(pos,Vector2(32,32)),Color(255,0,0,0.2),false, 1.0,false)
		var posit = currentEditingMachine.getAvailableGlobalFreeSlots()
		for slot in currentEditingMachine.getAvailableGlobalFreeSlots():
			var vec = level.getPosFromCellIdx(slot)
			draw_circle((vec+(tilemap.cell_size/2)),5,Color(255,0,0,0.2))


func hide_gui():
	gui.get_node("Control").set_visible(false)

func show_gui():
	gui.get_node("Control").set_visible(true)

func machine_mode():
	if state == 1:
		currentEditingMachine = level.createNewMachine(level.getCellIdxFromMousePos())
		#level.getAvailableGlobalFreeSlots()
		# if state 2 draw circles
	#if  = level.getCellIdxFromMousePos():
