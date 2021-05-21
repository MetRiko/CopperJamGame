extends Control

onready var level = Game.level

onready var editor = $Panel/Margin/VBox/Editor
onready var instructionsButtons = $Panel/Margin/VBox/InstructionsButtons

var selectedMachine = null
var selectedModuleLocalIdx = null

const ALL_INSTRUCTIONS = {
	'node_start': {
		'frameId': 1,
		'name': 'Node start'
	},
	'node_end': {
		'frameId': 2,
		'name': 'Node end'
	},
	'move_right': {
		'frameId': 8,
		'name': 'Move right'
	},
	'move_left': {
		'frameId': 9,
		'name': 'Move left'
	},
	'move_up': {
		'frameId': 10,
		'name': 'Move up'
	},
	'move_down': {
		'frameId': 11,
		'name': 'Move down'
	}
}

var instructionsOrder := []

func _init():
	for instructionId in ALL_INSTRUCTIONS:
		ALL_INSTRUCTIONS[instructionId].instructionId = instructionId

func _selectMachine(machine):
	selectedMachine = machine

func selectModule(machine, moduleLocalIdx):
	_selectMachine(machine)
	selectedModuleLocalIdx = moduleLocalIdx
	_updateButtons()

func _updateButtons():
	
	var module = getSelectedModule()
	if module == null:
		instructionsOrder = []
		for button in instructionsButtons.get_children():
			button.setInstructionData(null)
		return
	
	var instructionsData = module.getInstructions()
	instructionsOrder = module.getInstructionsOrder()
	
	for i in range(instructionsButtons.get_child_count()):
		var button = instructionsButtons.get_child(i)
		if i < instructionsOrder.size():
			button.setInstructionData(ALL_INSTRUCTIONS[instructionsOrder[i]])
		else:
			button.setInstructionData(null)
	
	var secondFromLastButton = instructionsButtons.get_child(instructionsButtons.get_child_count() - 2)
	var lastButton = instructionsButtons.get_child(instructionsButtons.get_child_count() - 1)
	secondFromLastButton.setInstructionData(ALL_INSTRUCTIONS['node_start'])
	lastButton.setInstructionData(ALL_INSTRUCTIONS['node_end'])

func getSelectedModule():
	if selectedMachine != null and selectedModuleLocalIdx != null:
		var module = selectedMachine.getModuleFromLocalIdx(selectedModuleLocalIdx)
		return module

func _ready():
	editor._setup(self)
	for button in instructionsButtons.get_children():
		button.connect("pressed", self, "onInstructionButtonPressed", [button.get_index()])
	
	_updateButtons()
		
func _input(event):
	if event.is_action_pressed("num0"):
		selectModule(Game.level.getFirstMachine(), Vector2(0, 0))
		
func onInstructionButtonPressed(buttonId):
	var button = instructionsButtons.get_child(buttonId)
	var instructionData = button.getInstructionData()
	editor.selectInstructionFromToolbar(instructionData)