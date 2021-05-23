extends HBoxContainer

const instructionButtonTscn = preload("res://Gui/NodeEditor/InstructionButton.tscn")

#func _callback(buttonData):

func connectButtons(target, methodName):
	for button in get_children():
		button.connect("pressed", target, methodName, [button.getInstructionData()])

func setButtons(instructionsButtonsData):
	clearButtons()
	for data in instructionsButtonsData:
		var newButton = instructionButtonTscn.instance()
		add_child(newButton)
		newButton.setInstructionData(data)

func _ready():
	clearButtons()
		
func clearButtons():
	for button in get_children():
		button.queue_free()
	
