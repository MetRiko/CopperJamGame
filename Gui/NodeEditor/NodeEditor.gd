extends Control

onready var editor = $Panel/Margin/VBox/Editor
onready var instructions = $Panel/Margin/VBox/Instructions

var availableInstructions = [
	{
		'instructionName': "MR",
		'frameId': 8
	},
	{
		'instructionName': "ML",
		'frameId': 9
	},
	{
		'instructionName': "MU",
		'frameId': 10
	},
	{
		'instructionName': "MD",
		'frameId': 11
	}
]

func _ready():
	for button in instructions.get_children():
		button.connect("pressed", self, "onInstructionButtonPressed", [button.get_index()])
		
		
func onInstructionButtonPressed(buttonId):
	if buttonId < availableInstructions.size():
		editor.selectInstructionFromToolbar(availableInstructions[buttonId])
	else:
		editor.selectInstructionFromToolbar(null)
