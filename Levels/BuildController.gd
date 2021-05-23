extends Node2D

onready var tilemap = Game.tilemap
onready var level = Game.level
onready var gui = Game.gui
onready var nodeEditor = Game.nodeEditor

var state := 0
var currentEditingMachine = null
export var playerBuildRange := 180.0
var entityData
var currentMouseIdx = Vector2()
var currentHoveredMachine = null
var spriteRotation := 0
var isTargeted := 0
var targetBackup = null
var targetModule = null
const defaultColor = Color.white
const selectedColor = Color('#65e67a')
var currentHoveredModule = null
var currentSelectedModule = null
var moduleDataLocal

var onEnemy = false


func _ready():
	gui.connect("module_button_pressed", self, "build_object")

func build_object(moduleData):
	entityData = moduleData.moduleId
	moduleDataLocal = moduleData
	if entityData != null:
		$Sprite.frame = moduleData.frameId if moduleData.frameId != null else 0
		$Sprite.visible = true

func _process(delta):
	var mouseIdx = level.getCellIdxFromMousePos()
	if entityData != null:
		if state == 2:
			$Sprite.global_position = Vector2(level.getPosFromCellIdx(level.getCellIdxFromPos(get_global_mouse_position())))+Vector2(level.getCellSize()/2)
	
	if currentMouseIdx != mouseIdx:
		currentMouseIdx = mouseIdx
		var hoveredMachine = level.getMachineFromIdx(mouseIdx)
		
		onEnemy = level.getEntityFromIdx(mouseIdx) != null
		
		if state == 2 or state == 0:
#			if not is_instance_valid(currentHoveredModule):
#				currentHoveredModule = null
			if hoveredMachine != null:
				var hoveredModule = hoveredMachine.getModuleFromLocalIdx(hoveredMachine.getLocalMouseIdx())
				if currentHoveredModule != hoveredModule:
					if currentHoveredModule != null and currentHoveredModule != currentSelectedModule:
						currentHoveredModule.modulate = Color.white
					if hoveredModule != null and hoveredModule != currentSelectedModule:
						hoveredModule.modulate = Color(1.2, 1.2, 1.2, 1.0)
					currentHoveredModule = hoveredModule
			else:
				if currentHoveredModule != null and currentHoveredModule != currentSelectedModule:
					currentHoveredModule.modulate = Color.white
				currentHoveredModule = null

#		if not is_instance_valid(currentHoveredMachine):
#			currentHoveredMachine = null
		if currentHoveredMachine != hoveredMachine:
			if hoveredMachine != null:
				if state == 0 && pRangeToIdx() == true or state == 2 && pRangeToIdx() == true:
					hoveredMachine.setOutline(1.0, Color(1.0, 1.0, 1.0, 0.6))
				else: 
					hoveredMachine.setOutline(0)
			if currentHoveredMachine != null:
				currentHoveredMachine.setOutline(0)
			currentHoveredMachine = hoveredMachine 
	update()

func setCurrentEditingMachine(nextMachine):
	if currentEditingMachine != nextMachine:
		if currentEditingMachine != null:
			currentEditingMachine.disconnect("module_removed", self, "onModuleRemoved")
			currentEditingMachine.disconnect("machine_removed", self, "onMachineRemoved")
		if nextMachine != null:
			nextMachine.connect("module_removed", self, "onModuleRemoved")
			nextMachine.connect("machine_removed", self, "onMachineRemoved")
	currentEditingMachine = nextMachine

func selectModule(module):
	if module != null and currentSelectedModule != module:
		if currentSelectedModule != null:
			currentSelectedModule.modulate = Color.white
		var mouseIdx = currentHoveredMachine.getLocalMouseIdx()
		nodeEditor.selectModule(currentHoveredMachine, mouseIdx)
		currentSelectedModule = module
		currentSelectedModule.modulate = Color(1.4, 1.4, 1.4, 1.0)
		setCurrentEditingMachine(currentHoveredMachine)
	elif module == null:
		if currentSelectedModule != null:
			currentSelectedModule.modulate = Color.white
			nodeEditor.selectModule(null, Vector2(0, 0))
			currentSelectedModule = null
		state = 0
		hide_gui()

func onMachineRemoved(machine):
	if machine == currentHoveredMachine:
		currentHoveredMachine = null
	if machine == currentEditingMachine or not is_instance_valid(currentEditingMachine):
		currentEditingMachine = null
		state = 0

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
			if event.is_action_pressed("LMB")&& pRangeToIdx() == true:
				for idx in calcRange():
					setCurrentEditingMachine(currentHoveredMachine)
				changeState(2)
				show_gui()
				gui.get_node("ExitBuildMode").set_visible(true)
				
				selectModule(currentHoveredModule)

	if state == 1:
		if event.is_action_pressed("LMB") && pRangeToIdx() == true:
			show_gui()
			machine_mode()
			gui.get_node("ExitBuildMode").set_visible(true)
			changeState(2)
	elif state == 1:
		if event.is_action_pressed("RMB"):
			changeState(0)

	elif state == 2:
		
		if event.is_action_pressed("LMB"):
			if entityData != null:
				var mouseIdx = currentEditingMachine.getLocalMouseIdx()
				gui.addCopper(-int(moduleDataLocal.cost))
				currentEditingMachine.attachModule(entityData, mouseIdx, spriteRotation)
				entityData = null
				$Sprite.visible = false
			else:
				if not is_instance_valid(currentSelectedModule):
					currentSelectedModule = null
				selectModule(currentHoveredModule)

		if event.is_action_pressed("RMB"):
			var mouseIdx = currentEditingMachine.getLocalMouseIdx()
			currentEditingMachine.detachModule(mouseIdx)
			if entityData != null:
				entityData = null
				$Sprite.visible = false

func _draw():
	var mouseIdx = level.getCellIdxFromMousePos()
	var posOfSprite = Vector2(level.getPosFromCellIdx(level.getCellIdxFromPos(get_global_mouse_position())))+Vector2(level.getCellSize()/2)
	var hoveredMachine = level.getMachineFromIdx(mouseIdx)
	if state == 0:
		for idx in calcRange():
			if level.isObstacle(idx) == false && level.getMachineFromIdx(idx) == null: 
#				draw_rect(Rect2(level.getPosFromCellIdx(idx)+Vector2(level.getCellSize()*0.25),level.getCellSize()*0.5),Color(0,1,1,0.2),false,1,false)
				draw_rect(Rect2(level.getPosFromCellIdx(idx)+Vector2(2.0, 2.0),level.getCellSize() - Vector2(4.0, 4.0)),Color(0,1,1,0.05),true,1,false)
#			elif level.isObstacle(idx) == false && level.getMachineFromIdx(idx) != null: 
#				draw_rect(Rect2(level.getPosFromCellIdx(idx)-Vector2(1.5,1.5),level.getCellSize() + Vector2(4.0,4.0)),Color(0,1,1,0.8),false,1,false)
		if currentHoveredMachine == null:
			drawCursorSquare(Color(0.0,0.5,0.5,0.2))
	if state == 1:
		drawCursorSquare(Color(0.5,0,0.5,0.8))
	if state == 2:
		var pos = Vector2(level.getPosFromCellIdx(level.getCellIdxFromPos(get_global_mouse_position()) - Vector2(1,1)))+Vector2(level.getCellSize())
		if currentEditingMachine != null:
			var posit = currentEditingMachine.getAvailableGlobalFreeSlots()
			if posit.has(level.getCellIdxFromMousePos()):
				drawCursorSquare(Color(1,0,0,0.8))
			for slot in posit:
				var vec = level.getPosFromCellIdx(slot)
				draw_circle((vec+(level.getCellSize()/2)),5,Color(1,0,0,0.3))
			drawAllowedSides()

func onModuleRemoved(machine, moduleLocalIdx, module):
	if currentHoveredModule == module or not is_instance_valid(currentHoveredModule):
		currentHoveredModule = null
	if currentSelectedModule == module or not is_instance_valid(currentSelectedModule):
		currentSelectedModule = null
		selectModule(null)

func changeTargetModule():
	var mouseIdx = level.getCellIdxFromMousePos()
	if nodeEditor.selectModule(currentEditingMachine,mouseIdx) != null:
		if nodeEditor.selectModule(currentEditingMachine,mouseIdx).modulate == selectedColor:
			nodeEditor.selectModule(currentEditingMachine,mouseIdx).modulate = defaultColor
		elif nodeEditor.selectModule(currentEditingMachine,mouseIdx).modulate == defaultColor:
			if targetModule.modulate != nodeEditor.selectModule(currentEditingMachine,mouseIdx).modulate:
				targetModule.modulate = defaultColor
			nodeEditor.selectModule(currentEditingMachine,mouseIdx).modulate = selectedColor
	targetModule = null

func changeState(stateNum: int):
	state = stateNum
	if state != 2 && currentEditingMachine != null && currentEditingMachine.hasModules() == false:
		currentEditingMachine.queue_free()
		setCurrentEditingMachine(null)

func hide_gui():
	gui.get_node("Control").set_visible(false)
	gui.get_node("ColorRect").set_visible(false)

func show_gui():
	gui.get_node("Control").set_visible(true)
	gui.get_node("ColorRect").set_visible(true)

func machine_mode():
	if state == 1:
		setCurrentEditingMachine(level.createNewMachine(level.getCellIdxFromMousePos()))

func clear_target():
	targetModule.set_modulate(defaultColor)
	targetModule = null
	targetBackup = null

func drawCursorSquare(col: Color):
		var pos = Vector2(level.getPosFromCellIdx(level.getCellIdxFromPos(get_global_mouse_position()) - Vector2(1,1)))+Vector2(level.getCellSize()) + Vector2(4,4)
#		draw_rect(Rect2(pos,Vector2(24,24)),col,true, 1.5,false)
		draw_rect(Rect2(pos,Vector2(24,24)),col,true, 1.0,false)

func drawAllowedSides():
	var colorOfLine = Color(0.5, 0.5, 1, 0.9)
	if entityData != null:
		var posOfSprite = Vector2(level.getPosFromCellIdx(level.getCellIdxFromPos(get_global_mouse_position())))+Vector2(level.getCellSize()/2)
		var lineVectors = currentEditingMachine.getOffsetsIdForAvailableConnections(entityData,posOfSprite,spriteRotation)
		for offsetsId in lineVectors:
			if offsetsId == 0:
				draw_line(posOfSprite-Vector2(level.getCellSize().x*0.25,level.getCellSize().y*0.5),posOfSprite+Vector2(level.getCellSize().x*0.25,-level.getCellSize().y*0.5),colorOfLine,3,false)
			if offsetsId == 1:
				draw_line(posOfSprite+Vector2(level.getCellSize().x*0.5,level.getCellSize().y*0.25),posOfSprite+Vector2(level.getCellSize().x*0.5,-level.getCellSize().y*0.25),colorOfLine,3,false)
			if offsetsId == 2:
				draw_line(posOfSprite+Vector2(level.getCellSize().x*0.25,level.getCellSize().y*0.5),posOfSprite-Vector2(level.getCellSize().x*0.25,-level.getCellSize().y*0.5),colorOfLine,3,false)
			if offsetsId == 3:
				draw_line(posOfSprite-Vector2(level.getCellSize().x*0.5,level.getCellSize().y*0.25),posOfSprite-Vector2(level.getCellSize().x*0.5,-level.getCellSize().y*0.25),colorOfLine,3,false)

func calcRange():
	var positArray = []
	var playerIdx = level.get_node("Player").currentCellIdx
	var playerPos = level.getPosFromCellIdx(playerIdx)
	for  x in range(playerBuildRange*2/level.getCellSize().x):
		for  y in range(playerBuildRange*2/level.getCellSize().y):
			var posit = Vector2(x,y)+playerIdx - (floor(playerBuildRange/level.getCellSize().x)*Vector2(1,1))
			if playerBuildRange > (level.getPosFromCellIdx(posit) - playerPos).length():
				positArray.append(posit)
	return positArray
	positArray.clear()

func pRangeToIdx():
	for idx in calcRange():
		if level.getCellIdxFromMousePos() == idx:
			if idx == level.getCellIdxFromPos(get_global_mouse_position()):
				return true
