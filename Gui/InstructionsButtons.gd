extends HBoxContainer

const instructionButtonTscn = preload("res://Gui/NodeEditor/InstructionButton.tscn")

#func _callback(buttonData):

func connectButtonsHover(target, methodName):
	for button in get_children():
		button.connect("mouse_entered", target, methodName, [button, true])
		button.connect("mouse_exited", target, methodName, [button, false])

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
		remove_child(button)
		button.queue_free()
	
