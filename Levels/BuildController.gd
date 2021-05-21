extends Node2D

onready var tilemap = Game.tilemap
onready var level = Game.level
onready var gui = Game.gui

var state := 0
var currentEditingMachine = null

var entityData

var currentMouseIdx = Vector2()
var currentHoveredMachine = null

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
	update()
	
	var mouseIdx = level.getCellIdxFromMousePos()
	if currentMouseIdx != mouseIdx:
		currentMouseIdx = mouseIdx
		var hoveredMachine = level.getMachineFromIdx(mouseIdx)
		if currentHoveredMachine != hoveredMachine:
			if hoveredMachine != null:
				if state == 0:
					hoveredMachine.setOutline(2.0, Color(0.0, 1.0, 0.0, 0.7))
				else: 
					hoveredMachine.setOutline(0)
			if currentHoveredMachine != null:
				currentHoveredMachine.setOutline(0)
			currentHoveredMachine = hoveredMachine 

func _unhandled_input(event):
	if state ==0:
		if event.is_action_pressed("LMB"):
			if currentHoveredMachine != null:
				currentEditingMachine = currentHoveredMachine
				changeState(2)
				show_gui()
				gui.get_node("ExitBuildMode").set_visible(true)

	if state == 1:
		if event.is_action_pressed("LMB"): #state 2 attach module
			show_gui()
			machine_mode()
			gui.get_node("ExitBuildMode").set_visible(true)
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
	if state == 0 and currentHoveredMachine == null:
		var pos = Vector2(tilemap.map_to_world(level.getCellIdxFromPos(get_global_mouse_position()) - Vector2(1,1)))+Vector2(tilemap.cell_size)
		draw_rect(Rect2(pos,Vector2(32,32)),Color(0,1,0,0.8),false, 1.0,false)
	if state == 1:
		var pos = Vector2(tilemap.map_to_world(level.getCellIdxFromPos(get_global_mouse_position()) - Vector2(1,1)))+Vector2(tilemap.cell_size)
		draw_rect(Rect2(pos,Vector2(32,32)),Color(0,0,1,0.8),false, 1.0,false)
	if state == 2:
		var pos = Vector2(tilemap.map_to_world(level.getCellIdxFromPos(get_global_mouse_position()) - Vector2(1,1)))+Vector2(tilemap.cell_size)
		var posit = currentEditingMachine.getAvailableGlobalFreeSlots()
		if posit.has(level.getCellIdxFromMousePos()):
			draw_rect(Rect2(pos,Vector2(32,32)),Color(1,0,0,0.8),false, 1.0,false)
		for slot in posit:
			var vec = level.getPosFromCellIdx(slot)
			draw_circle((vec+(tilemap.cell_size/2)),5,Color(1,0,0,0.4))

func changeState(stateNum: int):
	state = stateNum
	if state != 2 && currentEditingMachine != null && currentEditingMachine.hasModules() == false:
		currentEditingMachine.queue_free()
		currentEditingMachine = null

func hide_gui():
	gui.get_node("Control").set_visible(false)

func show_gui():
	gui.get_node("Control").set_visible(true)

func machine_mode():
	if state == 1:
		currentEditingMachine = level.createNewMachine(level.getCellIdxFromMousePos())

