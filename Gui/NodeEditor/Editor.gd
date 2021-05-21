extends ColorRect

const nodeInstructionTscn = preload("res://Gui/NodeEditor/InstructionNode.tscn")

onready var level = Game.level
#onready var editor = $Panel/Margin/VBox/Editor
onready var gizmoSprite = $Gizmo/Sprite

var currentGizmoIdx = null

var currentCameraPos = Vector2()

var selectedInstructionFromToolbar = null

var nodeEditor = null

const NODE_SIZE = Vector2(32.0, 32.0)

func _setup(nodeEditor):
	self.nodeEditor = nodeEditor

func selectInstructionFromToolbar(instructionData):
	selectedInstructionFromToolbar = instructionData
	print(instructionData)
	if instructionData != null:
		gizmoSprite.frame = instructionData.frameId
		gizmoSprite.visible = true
	else:
		gizmoSprite.visible = false

func moveCamera(offset : Vector2):
	currentCameraPos += offset
	$Nodes.rect_position = currentCameraPos

func _input(event):
	if event.is_action_pressed("LMB"):
		if selectedInstructionFromToolbar != null and nodeEditor.selectedMachine != null:
			if currentGizmoIdx != null:
				var instructionId = selectedInstructionFromToolbar.instructionId
				var moduleLocalIdx = nodeEditor.selectedModuleLocalIdx
				createNode(instructionId, currentGizmoIdx, moduleLocalIdx, {})
			selectInstructionFromToolbar(null)

func getPosFromEditorIdx(editorIdx):
	var pos = rect_global_position + currentCameraPos + editorIdx * NODE_SIZE
	return pos

func createNode(instructionId, editorIdx, moduleLocalIdx, additionalData):
	var processor = nodeEditor.selectedMachine.getProcessor()
	var nodeData = processor.addNode(instructionId, currentGizmoIdx, moduleLocalIdx, {})
	var newNode = nodeInstructionTscn.instance()
	$Nodes.add_child(newNode)
	newNode.setNodeData(nodeData, nodeEditor.ALL_INSTRUCTIONS[nodeData.instructionId].frameId)
	newNode.rect_global_position = getPosFromEditorIdx(nodeData.editorIdx)
	
	
#func _displayNodes():
	

func _process(delta):
	
	var mousePos = get_global_mouse_position() - rect_global_position - currentCameraPos
	var mouseIdx = mousePos / level.getCellSize()
	mouseIdx.x = floor(mouseIdx.x)
	mouseIdx.y = floor(mouseIdx.y)
	if int(mouseIdx.x) % 2 == 0 and int(mouseIdx.y) % 2 == 0:
		currentGizmoIdx = mouseIdx
		var pos = level.tilemap.cell_size * mouseIdx + rect_global_position + currentCameraPos
		gizmoSprite.global_position = pos
		gizmoSprite.modulate.a = 1.0
	else:
		currentGizmoIdx = null
		var pos = get_global_mouse_position() - level.getHalfCellSize()
		gizmoSprite.modulate.a = 0.1
		gizmoSprite.global_position = pos
#		gizmoSprite.visible = false
		
	if Input.is_action_pressed("up"):
		moveCamera(Vector2(0, -4.0))
	if Input.is_action_pressed("down"):
		moveCamera(Vector2(0, 4.0))
	if Input.is_action_pressed("left"):
		moveCamera(Vector2(-4.0, 0))
	if Input.is_action_pressed("right"):
		moveCamera(Vector2(4.0, 0))
	
	update()
	
	
func _draw():
	for x in range(8):
		for y in range(10):
			var pos = Vector2(x * 2, y * 2) * level.getCellSize().x 
			pos.x += fmod(currentCameraPos.x, level.getCellSize().x * 2) - 2 * level.getCellSize().x
			pos.y += fmod(currentCameraPos.y, level.getCellSize().y * 2) - 2 * level.getCellSize().y
			draw_rect(Rect2(pos, level.getCellSize()), Color.red, false, 1)
