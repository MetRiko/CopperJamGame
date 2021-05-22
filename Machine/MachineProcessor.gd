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
#		moduleLocalIdx,
#	}
#}

var processingNodes = {}

var nodes = {}

func getNodes():
	return nodes

func restartProcess():
	processingNodes = {}
	
	var startNodes = getStartNodes()
	for node in startNodes:
		var hashedNodeEditorIdx = machine.hashIdx(node.editorIdx) 
		processingNodes[hashedNodeEditorIdx] = node
	
	makeStep()

func makeStep():
	
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
	if firstNode != null and targetNode != null:
		firstNode.targetNodes.append(targetNodeId)
		targetNode.sourceNodes.append(firstNodeId)
		return [firstNodeEditorIdx, targetNodeEditorIdx]
	return null

func getAllConnectionsIdxes():
	var idxes = []
	for node in nodes.values():
		var fromIdx = node.editorIdx
		for targetId in node.targetNodes:
			var toIdx = nodes[targetId].editorIdx
			idxes.append([fromIdx, toIdx])
	return idxes 

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
	var module = machine.getModuleFromLocalIdx(localModuleIdx)
	if module != null:
		module.callInstruction(instructionId)
	else:
		printerr("module doesn't exist")
