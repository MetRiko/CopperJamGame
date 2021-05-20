extends Node2D

onready var machine = get_parent()

#var code = {
#	nodes: [
#
#	],
#
#}

func justCallInstruction(localModuleIdx, instructionId):
	var module = machine.getModuleFromLocalIdx(localModuleIdx)
	if module != null:
		module.callInstruction(instructionId)
	else:
		printerr("module doesn't exist")
