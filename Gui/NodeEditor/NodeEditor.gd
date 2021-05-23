extends Control

onready var level = Game.level

onready var editor = $Panel/Margin/VBox/Editor
onready var instructionsButtons = $Panel/Margin/VBox/InstructionsButtons
onready var toolbar = $Panel/Margin/VBox/Toolbar

var selectedMachine = null
var selectedModuleLocalIdx = null

const ALL_INSTRUCTIONS = preload("res://Gui/NodeEditor/AllInstructions.gd").ALL_INSTRUCTIONS

func getToolbar():
	return toolbar

var instructionsOrder := []

func _init():
	for instructionId in ALL_INSTRUCTIONS:
		ALL_INSTRUCTIONS[instructionId].instructionId = instructionId

func _selectMachine(machine):
	if selectedMachine != machine:
		if selectedMachine != null:
			selectedMachine.disconnect("module_removed", self, "onModuleRemoved")
			selectedMachine.connect("machine_removed", self, "onMachineRemoved")
		if machine != null:
			machine.connect("module_removed", self, "onModuleRemoved")
			machine.connect("machine_removed", self, "onMachineRemoved")
	selectedMachine = machine

func selectModule(machine, moduleLocalIdx):
	if machine != null:
		visible = true
		_selectMachine(machine)
		selectedModuleLocalIdx = moduleLocalIdx
		_updateButtons()
		_updateEditor()
	else:
		visible = false
		_selectMachine(machine)
		selectedModuleLocalIdx = null
		_updateButtons()
		_updateEditor()
		
	
func _updateEditor():
	editor.updateEditor()

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
	
	var thirdFromLastButton = instructionsButtons.get_child(instructionsButtons.get_child_count() - 3)
	var secondFromLastButton = instructionsButtons.get_child(instructionsButtons.get_child_count() - 2)
	var lastButton = instructionsButtons.get_child(instructionsButtons.get_child_count() - 1)
	thirdFromLastButton.setInstructionData(ALL_INSTRUCTIONS['nop'])
	secondFromLastButton.setInstructionData(ALL_INSTRUCTIONS['node_start'])
	lastButton.setInstructionData(ALL_INSTRUCTIONS['node_end'])

func getSelectedModule():
	if selectedMachine != null and selectedModuleLocalIdx != null:
		var module = selectedMachine.getModuleFromLocalIdx(selectedModuleLocalIdx)
		return module
	return null

func onMachineRemoved(removedMachine):
	if selectedMachine == removedMachine:
		selectedMachine = null
		selectModule(null, Vector2())

func onModuleRemoved(machine, moduleLocalIdx, module):
	if machine == selectedMachine and selectedModuleLocalIdx == moduleLocalIdx:
		selectModule(selectedMachine, moduleLocalIdx)
	else:
		editor.updateEditor()

func _ready():
	editor._setup(self)
	for button in instructionsButtons.get_children():
		button.connect("pressed", self, "onInstructionButtonPressed", [button.get_index()])
	
	selectModule(null, Vector2(0, 0))
		
func _input(event):
	if event.is_action_pressed("num0"):
		selectModule(Game.level.getFirstMachine(), Vector2(0, 0))
		
func onInstructionButtonPressed(buttonId):
	var button = instructionsButtons.get_child(buttonId)
	var instructionData = button.getInstructionData()
	editor.selectInstructionFromToolbar(instructionData)
