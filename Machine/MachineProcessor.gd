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

var nodes = {
	
}

func getNodes():
	return nodes

func addNode(instructionId : String, editorIdx : Vector2, moduleLocalIdx : Vector2, additionalData = {}):
	var nodeData = null
	var hashedEditorIdx = machine.hashIdx(editorIdx)
	if nodes.has(hashedEditorIdx):
		push_error("NodeEditor: This idx is occupied")
	else:
		nodeData = {
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
