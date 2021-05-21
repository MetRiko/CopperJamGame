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

var nodes = {}

func getNodes():
	return nodes

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
