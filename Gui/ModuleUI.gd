extends Control

onready var nodeEditor = Game.nodeEditor

onready var instructionsButtons = $InstructionsButtons

var currentModule = null

# Called when the node enters the scene tree for the first time.
func _ready():
	nodeEditor.connect("buttons_instructions_changed", self, "onButtonsInstructionsChange")
	
func onButtonsInstructionsChange(newButtonsInstructions, module):
	instructionsButtons.setButtons(newButtonsInstructions)
	instructionsButtons.connectButtons(self, "onButtonClick")
	currentModule = module
	if module == null:
		visible = false
	else:
		visible = true
#		rect_global_position = Vector2(10, 10)
		rect_global_position = module.global_position
		print(rect_global_position)

func onButtonClick(buttonData):
	print(buttonData)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
