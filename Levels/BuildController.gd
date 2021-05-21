extends Node2D

onready var tilemap = Game.tilemap
onready var level = Game.level
onready var gui = Game.gui

var state := 0
var currentEditingMachine = null
export var playerBuildRange := 180.0
var entityData
var currentMouseIdx = Vector2()
var currentHoveredMachine = null
var spriteRotation := 0


func _ready():
	gui.connect("module_button_pressed", self, "build_object")

func build_object(moduleData):
	entityData = moduleData.moduleId
	if entityData != null:
		$Sprite.frame = moduleData.frameId if moduleData.frameId != null else 0
		$Sprite.visible = true

func _process(delta):
	var mouseIdx = level.getCellIdxFromMousePos()
	if entityData != null:
		if state == 2:
			$Sprite.global_position = Vector2(tilemap.map_to_world(level.getCellIdxFromPos(get_global_mouse_position())))+Vector2(tilemap.cell_size/2)
	if currentMouseIdx != mouseIdx:
		currentMouseIdx = mouseIdx
		var hoveredMachine = level.getMachineFromIdx(mouseIdx)
		if currentHoveredMachine != hoveredMachine:
			if hoveredMachine != null:
				if state == 0 || state == 2:
					hoveredMachine.setOutline(2.0, Color(0.0, 1.0, 0.0, 0.7))
				else: 
					hoveredMachine.setOutline(0)
			if currentHoveredMachine != null:
				currentHoveredMachine.setOutline(0)
			currentHoveredMachine = hoveredMachine 
	update()

func _unhandled_input(event):
	if entityData != null:
		if event.is_action_pressed("rotate_right"):
			$Sprite.rotate(PI/2)
			spriteRotation = (spriteRotation+1)%4
		if event.is_action_pressed("rotate_left"):
			$Sprite.rotate(-PI/2)
			spriteRotation = (spriteRotation-1)%4
	if state == 0:
		if currentHoveredMachine != null:
			if event.is_action_pressed("LMB"):
				for idx in calcRange():
					currentEditingMachine = currentHoveredMachine
					changeState(2)
					show_gui()
					gui.get_node("ExitBuildMode").set_visible(true)

	if state == 1:
		if event.is_action_pressed("LMB"):
			show_gui()
			machine_mode()
			gui.get_node("ExitBuildMode").set_visible(true)
			state = 2
	elif state == 1:
		if event.is_action_pressed("RMB"):
			state = 0

	elif state == 2:
		if event.is_action_pressed("LMB"):
			if currentHoveredMachine != null:
				currentEditingMachine = currentHoveredMachine
			var mouseIdx = currentEditingMachine.getLocalMouseIdx()
			if entityData != null:
				currentEditingMachine.attachModule(entityData, mouseIdx, spriteRotation)
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
	var mouseIdx = level.getCellIdxFromMousePos()
	var posOfSprite = Vector2(tilemap.map_to_world(level.getCellIdxFromPos(get_global_mouse_position())))+Vector2(tilemap.cell_size/2)
	var hoveredMachine = level.getMachineFromIdx(mouseIdx)
	if state == 0 and currentHoveredMachine == null:
		for idx in calcRange():
			if level.isObstacle(idx) == false && level.getMachineFromIdx(idx) == null: 
				draw_rect(Rect2(level.getPosFromCellIdx(idx)+Vector2(tilemap.cell_size*0.25),tilemap.cell_size*0.5),Color(0,1,1,0.2),false,1,false)
		drawCursorSquare(Color(0,1,0,0.8))
	if state == 1:
		drawCursorSquare(Color(0,0,1,0.8))
	if state == 2:
		var pos = Vector2(tilemap.map_to_world(level.getCellIdxFromPos(get_global_mouse_position()) - Vector2(1,1)))+Vector2(tilemap.cell_size)
		var posit = currentEditingMachine.getAvailableGlobalFreeSlots()
		if posit.has(level.getCellIdxFromMousePos()):
			drawCursorSquare(Color(1,0,0,0.8))
		for slot in posit:
			var vec = level.getPosFromCellIdx(slot)
			draw_circle((vec+(tilemap.cell_size/2)),5,Color(1,0,0,0.4))
		drawAllowedSides()



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

func drawCursorSquare(col: Color):
		var pos = Vector2(tilemap.map_to_world(level.getCellIdxFromPos(get_global_mouse_position()) - Vector2(1,1)))+Vector2(tilemap.cell_size)
		draw_rect(Rect2(pos,Vector2(32,32)),col,false, 1.0,false)

func drawAllowedSides():
	var colorOfLine = Color(0.5, 0.5, 1, 0.9)
	if entityData != null:
		var posOfSprite = Vector2(tilemap.map_to_world(level.getCellIdxFromPos(get_global_mouse_position())))+Vector2(tilemap.cell_size/2)
		var lineVectors = currentEditingMachine.getOffsetsIdForAvailableConnections(entityData,posOfSprite,spriteRotation)
		for offsetsId in lineVectors:
			if offsetsId == 0:
				draw_line(posOfSprite-Vector2(tilemap.cell_size.x*0.25,tilemap.cell_size.y*0.5),posOfSprite+Vector2(tilemap.cell_size.x*0.25,-tilemap.cell_size.y*0.5),colorOfLine,3,false)
			if offsetsId == 1:
				draw_line(posOfSprite+Vector2(tilemap.cell_size.x*0.5,tilemap.cell_size.y*0.25),posOfSprite+Vector2(tilemap.cell_size.x*0.5,-tilemap.cell_size.y*0.25),colorOfLine,3,false)
			if offsetsId == 2:
				draw_line(posOfSprite+Vector2(tilemap.cell_size.x*0.25,tilemap.cell_size.y*0.5),posOfSprite-Vector2(tilemap.cell_size.x*0.25,-tilemap.cell_size.y*0.5),colorOfLine,3,false)
			if offsetsId == 3:
				draw_line(posOfSprite-Vector2(tilemap.cell_size.x*0.5,tilemap.cell_size.y*0.25),posOfSprite-Vector2(tilemap.cell_size.x*0.5,-tilemap.cell_size.y*0.25),colorOfLine,3,false)



func calcRange():
	var positArray = []
	var playerIdx = level.get_node("Player").currentCellIdx
	var playerPos = level.getPosFromCellIdx(playerIdx)
	for  x in range(playerBuildRange*2/tilemap.cell_size.x):
		for  y in range(playerBuildRange*2/tilemap.cell_size.y):
			var posit = Vector2(x,y)+playerIdx - (floor(playerBuildRange/tilemap.cell_size.x)*Vector2(1,1))
			if playerBuildRange > (level.getPosFromCellIdx(posit) - playerPos).length():
				positArray.append(posit)
	return positArray
	positArray.clear()
