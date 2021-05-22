extends ColorRect

const nodeInstructionTscn = preload("res://Gui/NodeEditor/InstructionNode.tscn")
const nodesConnectionTscn = preload("res://Gui/NodeEditor/NodesConnection.tscn")
const processingNodeGizmoTscn = preload("res://Gui/NodeEditor/ProcessingNodeGizmo.tscn")

onready var level = Game.level
#onready var editor = $Panel/Margin/VBox/Editor
onready var gizmoSprite = $Gizmo/Sprite

var currentGizmoIdx = null
var currentCameraPos = Vector2()
var selectedInstructionFromToolbar = null

var nodeEditor = null

const NODE_SIZE = Vector2(32.0, 32.0)

var selectedNode = null
var dragState = 0

var connections = []

func _ready():
	selectInstructionFromToolbar(null)

func _setup(nodeEditor):
	self.nodeEditor = nodeEditor
	
	
	var toolbar = nodeEditor.getToolbar()
	
	toolbar.get_node("PlayButton").connect("pressed", self, "onPlayButtonPressed")
	toolbar.get_node("PauseButton").connect("pressed", self, "onPauseButtonPressed")
	toolbar.get_node("RestartButton").connect("pressed", self, "onRestartButtonPressed")
	toolbar.get_node("StopButton").connect("pressed", self, "onStopButtonPressed")
	

func updateEditor():
	_redrawNodes()
	_redrawConnections()
	_redrawProcessingNodes()

func selectInstructionFromToolbar(instructionData):
	selectedInstructionFromToolbar = instructionData
#	print(instructionData)
	if instructionData != null:
		gizmoSprite.frame = instructionData.frameId
#		gizmoSprite.visible = true
#	else:
#		gizmoSprite.visible = false

func moveCamera(offset : Vector2):
	currentCameraPos += offset
	$Nodes.rect_position = currentCameraPos
	$Connections.rect_position = currentCameraPos
	$ProcessingGizmos.rect_position = currentCameraPos

func _input(event):
	if event.is_action_pressed("LMB"):
		if nodeEditor.selectedMachine != null:
			if selectedInstructionFromToolbar != null:
				if currentGizmoIdx != null:
					var instructionId = selectedInstructionFromToolbar.instructionId
					var moduleLocalIdx = nodeEditor.selectedModuleLocalIdx
					createNode(instructionId, currentGizmoIdx, moduleLocalIdx, {})
				selectInstructionFromToolbar(null)
			elif dragState == 0 and currentGizmoIdx != null:
				var processor = nodeEditor.selectedMachine.getProcessor()
				var node = processor.getNodeFromEditorIdx(currentGizmoIdx)
				if node != null:
					selectedNode = node
					dragState = 1

	if event.is_action_released("LMB"):
		if dragState == 1:
			if currentGizmoIdx != null:
				var processor = nodeEditor.selectedMachine.getProcessor()
				var node = processor.getNodeFromEditorIdx(currentGizmoIdx)
				if node != null and selectedNode != node:
					createConnection(selectedNode.editorIdx, node.editorIdx)
			dragState = 0
			selectedNode = null
			
			
	if event.is_action_pressed("RMB"):
		if nodeEditor.selectedMachine != null and currentGizmoIdx != null:
			var processor = nodeEditor.selectedMachine.getProcessor()
			if processor.hasNode(currentGizmoIdx):
				removeNode(currentGizmoIdx)
			
func getLocalPosFromEditorIdx(editorIdx):
	var pos = editorIdx * NODE_SIZE
	return pos

func getPosFromEditorIdx(editorIdx):
	var pos = rect_global_position + currentCameraPos + editorIdx * NODE_SIZE * 2.0
	return pos

func _redrawProcessingNodes():
	
	
	for gizmo in $ProcessingGizmos.get_children():
		gizmo.queue_free()
	
	if nodeEditor.selectedMachine == null:
		return
	
	var processor = nodeEditor.selectedMachine.getProcessor()
	var processingNodes = processor.getProcessingNodesIdxes()
	
	for processingNodeIdx in processingNodes:
		var newGizmo = processingNodeGizmoTscn.instance()
		$ProcessingGizmos.add_child(newGizmo)
		newGizmo.rect_position = getLocalPosFromEditorIdx(processingNodeIdx) + NODE_SIZE * 0.25
#		print(processingNodeIdx) ???????????? WHY it's moving 32 pixels when I'm adding 16 ^^^^
#		print(getLocalPosFromEditorIdx(processingNodeIdx))
#		print(getLocalPosFromEditorIdx(processingNodeIdx) + NODE_SIZE * 0.5)

func _redrawConnections():
	for connection in $Connections.get_children():
		connection.queue_free()
	
	if nodeEditor.selectedMachine == null:
		return
		
	var processor = nodeEditor.selectedMachine.getProcessor()
	var connections = processor.getAllConnectionsIdxes()
	for pairIdxes in connections:
		var newConnection = nodesConnectionTscn.instance()
		$Connections.add_child(newConnection)
		var beginPos = getPosFromEditorIdx(pairIdxes[0]) + NODE_SIZE * 0.5
		var endPos = getPosFromEditorIdx(pairIdxes[1]) + NODE_SIZE * 0.5
		var vec = (endPos - beginPos).normalized()
		var angle = vec.angle()
		var fix = (1.0 - abs(fmod(abs(vec.angle()), PI * 0.5)-PI*0.25) / (PI * 0.25)) * (NODE_SIZE.x * sqrt(2.0) - NODE_SIZE.x) * 0.5
		var adjustedBeginPos = beginPos + vec * (NODE_SIZE.x * 0.45 + fix)
		var adjustedEndPos = endPos - vec * (NODE_SIZE.x * 0.5 + fix)
		newConnection.setPoints(adjustedBeginPos, adjustedEndPos, Color('#2aceab'))

func createConnection(beginNodeEditorIdx, endNodeEditorIdx):
	var processor = nodeEditor.selectedMachine.getProcessor()
	processor.connectNodes(beginNodeEditorIdx, endNodeEditorIdx)
		
	_redrawConnections()

func _redrawNodes():
	for node in $Nodes.get_children():
		node.queue_free()
		
	if nodeEditor.selectedMachine == null:
		return
		
	var processor = nodeEditor.selectedMachine.getProcessor()
	var nodes = processor.getNodes()
	for nodeData in nodes.values():
		var newNode = nodeInstructionTscn.instance()
		$Nodes.add_child(newNode)
		newNode.setNodeData(nodeData, nodeEditor.ALL_INSTRUCTIONS[nodeData.instructionId].frameId)
		newNode.rect_global_position = getPosFromEditorIdx(nodeData.editorIdx)

func createNode(instructionId, editorIdx, moduleLocalIdx, additionalData):
	var processor = nodeEditor.selectedMachine.getProcessor()
	processor.addNode(instructionId, editorIdx, moduleLocalIdx, {})
	_redrawNodes()

func removeNode(editorIdx):
	var processor = nodeEditor.selectedMachine.getProcessor()
	processor.removeNode(editorIdx)
	_redrawNodes()
	_redrawConnections()
	_redrawProcessingNodes()
	
func onPlayButtonPressed():
	var selectedMachine = nodeEditor.selectedMachine
	if selectedMachine != null:
		var processor = selectedMachine.getProcessor()
		processor.makeStep()
		_redrawProcessingNodes()
	
func onPauseButtonPressed():
	pass
		
func onStopButtonPressed():
	pass
	
func onRestartButtonPressed():
	var selectedMachine = nodeEditor.selectedMachine
	if selectedMachine != null:
		var processor = selectedMachine.getProcessor()
		processor.restartProcess()
		_redrawProcessingNodes()
	
func _process(delta):
	
	var mousePos = get_global_mouse_position() - rect_global_position - currentCameraPos
	var mouseIdx = mousePos / level.getCellSize()
	mouseIdx.x = floor(mouseIdx.x)
	mouseIdx.y = floor(mouseIdx.y)
	
	if int(mouseIdx.x) % 2 == 0 and int(mouseIdx.y) % 2 == 0:
		currentGizmoIdx = mouseIdx / 2
		var pos = level.tilemap.cell_size * mouseIdx + rect_global_position + currentCameraPos
		gizmoSprite.global_position = pos
		if selectedInstructionFromToolbar != null:
			gizmoSprite.modulate = Color('#2aceab')
			gizmoSprite.modulate.a = 1.0
			gizmoSprite.visible = true
		elif nodeEditor.selectedMachine != null and nodeEditor.selectedMachine.getProcessor().getNodeFromEditorIdx(currentGizmoIdx) != null:
			gizmoSprite.modulate = Color('#ceab2a')
			gizmoSprite.modulate.a = 1.0
			gizmoSprite.visible = true
			gizmoSprite.frame = 0
		else:
			gizmoSprite.visible = false
		
	else:
		currentGizmoIdx = null
		var pos = get_global_mouse_position() - level.getHalfCellSize()
		gizmoSprite.global_position = pos
		if selectedInstructionFromToolbar != null:
			gizmoSprite.modulate.a = 0.1
			gizmoSprite.visible = true
		else:
			gizmoSprite.visible = false
			
		
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
	
	# Editor grid
	
	for x in range(8):
		for y in range(10):
			var pos = Vector2(x * 2, y * 2) * level.getCellSize().x 
			pos.x += fmod(currentCameraPos.x, level.getCellSize().x * 2) - 2 * level.getCellSize().x
			pos.y += fmod(currentCameraPos.y, level.getCellSize().y * 2) - 2 * level.getCellSize().y
			draw_rect(Rect2(pos, level.getCellSize()), Color(0.12, 0.12, 0.12, 1.0), false, 1)

	# Drag and drop arrow
	
	if dragState == 1:
#		var processor = nodeEditor.selectedMachine.getProcessor()
		var endPos = get_global_mouse_position() - rect_global_position# + NODE_SIZE * 0.5
		var beginPos = getPosFromEditorIdx(selectedNode.editorIdx) - rect_global_position + NODE_SIZE * 0.5
		var vec = (endPos - beginPos).normalized()
		var fix = (1.0 - abs(fmod(abs(vec.angle()), PI * 0.5)-PI*0.25) / (PI * 0.25)) * (NODE_SIZE.x * sqrt(2.0) - NODE_SIZE.x) * 0.5
		var adjustedBeginPos = beginPos + vec * (NODE_SIZE.x * 0.45 + fix)
		draw_line(adjustedBeginPos, endPos, Color('#ceab2a'), 2, true)
#		print(1.0 - abs(fmod(abs(vec.angle()), PI * 0.5)-PI*0.25) / (PI * 0.25))
