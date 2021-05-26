extends Button

const ALL_INSTRUCTIONS = preload("res://Gui/ActionsPanel/AllInstructions.gd").ALL_INSTRUCTIONS

var instruction = null
var selectedModule = null

func setInstruction(instruction, module):
	if instruction != null:
		self.instruction = instruction
		$Sprite.frame = ALL_INSTRUCTIONS[instruction.instructionId].frameId
		selectedModule = module

func _pressed():
	if instruction != null and selectedModule != null and is_instance_valid(selectedModule):
		selectedModule.callInstruction(instruction.instructionId) 
