extends Node2D

onready var machine = get_parent()

const ALL_INSTRUCTIONS = {
	'move_left': {
		
	},
	'move_right': {
		
	},
	'move_up': {
		
	},
	'move_down': {
		
	}
}

#const EXAMPLE_NODE = {
#	id: {
#		instructionId,
#		additionalData,
#		targetNodes = [id, id, id]
#		sourceNodes = [id, id, id]
#		editorIdx,
#		moduleLocalIdx
#	}
#}

var processingNodes = {}

var processingInstructionsGroups = {
	#'move': []
	#per module
}

var nodes = {}

func _ready():
	randomize()

func getNodes():
	return nodes

func _resetProcessingInstructionsGroups():
	processingInstructionsGroups = {}
	
func _addProcessingInstruction(instructionId, moduleLocalIdx, processingNode):
	if instructionId == 'node_end' or instructionId == 'node_start':
		return
	elif instructionId == 'move_left' or instructionId == 'move_right' or instructionId == 'move_up' or instructionId == 'move_down':
		if not processingInstructionsGroups.has('move'):
			processingInstructionsGroups['move'] = []
		processingInstructionsGroups['move'].append([instructionId, moduleLocalIdx, processingNode])
	else:
		var hashedIdx = machine.hashIdx(moduleLocalIdx)
		if not processingInstructionsGroups.has(hashedIdx):
			processingInstructionsGroups[hashedIdx] = []
		processingInstructionsGroups[hashedIdx].append([instructionId, moduleLocalIdx, processingNode])
	
func _calculateProcessingInstructionsGroups():
	_resetProcessingInstructionsGroups()
	for processingNode in processingNodes.values():
		_addProcessingInstruction(processingNode.instructionId, processingNode.moduleLocalIdx, processingNode)

func _callProperInstructions():
	_calculateProcessingInstructionsGroups()
	
	var failedConditions = {}
	
	for group in processingInstructionsGroups.values():
		var elementsToRemove = []
		for groupElement in group:
			var instructionId = groupElement[0]
			var moduleLocalIdx = groupElement[1]
			var module = machine.getModuleFromLocalIdx(moduleLocalIdx)
			if module.isConditionInstruction(instructionId) == true:
				var condition = justCallInstruction(moduleLocalIdx, instructionId)
				if condition == false:
					var processingNode = groupElement[2]
					var processingNodeId = machine.hashIdx(processingNode.editorIdx)
					processingNodes.erase(processingNodeId)
				elementsToRemove.append(groupElement)
		for elementToRemove in elementsToRemove:
			group.erase(elementToRemove)
	#					for processingNode in processingNodes.values():
	#						if processingNode.moduleLocalIdx == moduleLocalIdx and processingNode.instructionId == instructionId:
	#							var hashedProcessingNodeEditorIdx = machine.hashIdx(processingNode.editorIdx)
	#							failedConditions[hashedProcessingNodeEditorIdx] = false
	
#	for failedCondition in failedConditions.keys():
#		processingNodes.erase(failedCondition)
		
#	_calculateProcessingInstructionsGroups()
	
	
	for group in processingInstructionsGroups.values():
		var randomInstruction = group[randi() % group.size()]
		var instructionId = randomInstruction[0]
		var moduleLocalIdx = randomInstruction[1]
		justCallInstruction(moduleLocalIdx, instructionId)
		
	
func restartProcess():
	processingNodes = {}
	
	var startNodes = getStartNodes()
	for node in startNodes:
		var hashedNodeEditorIdx = machine.hashIdx(node.editorIdx) 
		processingNodes[hashedNodeEditorIdx] = node
	
	makeStep()

func makeStep():
	
	_callProperInstructions()
	
	var newProcessingNodes = {}
	
	for processingNode in processingNodes.values():
		if processingNode.instructionId == 'node_start':
			for targetNodeId in processingNode.targetNodes:
				var targetNode = nodes[targetNodeId]
				newProcessingNodes[targetNodeId] = targetNode
		else:
			for targetNodeId in processingNode.targetNodes:
				var targetNode = nodes[targetNodeId]
				if targetNode.instructionId == 'node_end':
					var starts = getStartNodes()
					for startNode in starts:
						for targetNodeId2 in startNode.targetNodes:
#						var hashedStartNodeIdx = machine.hashIdx(startNode.editorIdx)
							newProcessingNodes[targetNodeId2] = nodes[targetNodeId2]
				else:
					newProcessingNodes[targetNodeId] = nodes[targetNodeId]
	
	processingNodes = newProcessingNodes

func getProcessingNodesIdxes():
	var idxes = []
	for node in processingNodes.values():
		idxes.append(node.editorIdx)
	return idxes

func getStartNodes():
	var startNodes = []
	for node in nodes.values():
		if node.instructionId == 'node_start':
			startNodes.append(node)
	return startNodes

func getNodeFromEditorIdx(editorIdx):
	var hashedEditorIdx = machine.hashIdx(editorIdx)
	return nodes.get(hashedEditorIdx)

func connectNodes(firstNodeEditorIdx, targetNodeEditorIdx):
	var firstNodeId = machine.hashIdx(firstNodeEditorIdx)
	var targetNodeId = machine.hashIdx(targetNodeEditorIdx)
	
	var firstNode = nodes.get(firstNodeId)
	var targetNode = nodes.get(targetNodeId)
	if firstNode != null and targetNode != null and firstNode.instructionId != 'node_end' and targetNode.instructionId != 'node_start':
		firstNode.targetNodes.append(targetNodeId)
		targetNode.sourceNodes.append(firstNodeId)
		return [firstNodeEditorIdx, targetNodeEditorIdx]
	return null

func hasNode(editorIdx):
	var hashedIdx = machine.hashIdx(editorIdx)
	var node = nodes.get(hashedIdx)
	return node != null

func getAllConnectionsIdxes():
	var idxes = []
	for node in nodes.values():
		var fromIdx = node.editorIdx
		for targetId in node.targetNodes:
			var toIdx = nodes[targetId].editorIdx
			idxes.append([fromIdx, toIdx])
	return idxes

func removeNodesRelatedToModule(moduleLocalIdx):
	for node in nodes.values():
		if node.instructionId != 'node_start' and node.instructionId != 'node_end':
			if node.moduleLocalIdx == moduleLocalIdx:
				var hashedIdx = machine.hashIdx(node.editorIdx)
				addNode('missing_instruction', node.editorIdx, moduleLocalIdx, {})
#				removeNode(node.editorIdx)

func removeNode(editorIdx : Vector2):
	var hashedEditorIdx = machine.hashIdx(editorIdx)
	var node = nodes.get(hashedEditorIdx)
	if node != null:
		for sourceNodeId in node.sourceNodes:
			var sourceNode = nodes[sourceNodeId]
			sourceNode.targetNodes.erase(hashedEditorIdx)
		for targetNodeId in node.targetNodes:
			var targetNode = nodes[targetNodeId]
			targetNode.sourceNodes.erase(hashedEditorIdx)
		nodes.erase(hashedEditorIdx)
		
		processingNodes = {}
		


func addNode(instructionId : String, editorIdx : Vector2, moduleLocalIdx : Vector2, additionalData = {}):
	
	var hashedEditorIdx = machine.hashIdx(editorIdx)
	if nodes.has(hashedEditorIdx):
		var node = nodes[hashedEditorIdx]
		node.instructionId = instructionId
		node.additionalData = additionalData
		return node
	else:
		var nodeData = {
			'instructionId': instructionId,
			'additionalData': {},
			'targetNodes': [],
			'sourceNodes': [],
			'editorIdx': editorIdx,
			'moduleLocalIdx': moduleLocalIdx
		}
		nodes[hashedEditorIdx] = nodeData
		return nodeData

func justCallInstruction(localModuleIdx, instructionId):
	if instructionId == 'nop' or instructionId == 'missing_instruction':
		return true
	var module = machine.getModuleFromLocalIdx(localModuleIdx)
	if module != null:
		return module.callInstruction(instructionId)
	else:
		printerr("module doesn't exist")
	return false
