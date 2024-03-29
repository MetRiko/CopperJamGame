extends Control

signal buttons_instructions_changed

onready var level = Game.level

onready var editor = $Panel/Margin/VBox/EditorAnchor/Editor
onready var instructionsButtons = $Panel/Margin/VBox/InstructionsButtons
onready var instructionsButtons2 = $Panel/Margin/VBox/HBox/InstructionsButtons2
onready var toolbar = $Panel/Margin/VBox/HBox/Toolbar
onready var actionInfo = $Panel/Margin/VBox/ActionInfoBack/ActionInfo
onready var pic = level.getPlayerInputController()

var selectedMachine = null
var selectedModuleLocalIdx = null

const ALL_INSTRUCTIONS = preload("res://Gui/ActionsPanel/AllInstructions.gd").ALL_INSTRUCTIONS

const ALL_INSTRUCTIONS_FOR_BOTTOM = [
	ALL_INSTRUCTIONS['nop'], ALL_INSTRUCTIONS['node_start'], ALL_INSTRUCTIONS['node_end']
]

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
			selectedMachine.disconnect("machine_removed", self, "onMachineRemoved")
		if machine != null:
			machine.connect("module_removed", self, "onModuleRemoved")
			machine.connect("machine_removed", self, "onMachineRemoved")
	selectedMachine = machine

func onModuleSelected(module):
#	print(module)
	if module != null:
		selectModule(module.getMachine(), module.getLocalIdx())
		editor.setCamera(Vector2(0.0, 0.0))
	else:
		selectModule(null)

func selectModule(machine, moduleLocalIdx := Vector2()):
	if machine != null:
		_selectMachine(machine)
		selectedModuleLocalIdx = moduleLocalIdx
		_updateButtons()
		_updateEditor()
	else:
		_selectMachine(machine)
		selectedModuleLocalIdx = null
		_updateButtons()
		_updateEditor()
	
	if machine != null and pic.isBuildingState():
		show()
		editor.updateEditor()
	else:
		hide()
	
func onStateChanged(state):
	var machine = pic.getSelectedMachine()
	if machine != null and is_instance_valid(machine) and pic.isBuildingState():
		show()
		editor.updateEditor()
	else:
		hide()
	
func _updateEditor():
	editor.updateEditor()

func onInstructionButtonHover(button, hovered):
	if hovered == true:
		actionInfo.text = button.getInstructionData().name
	else:
		actionInfo.text = ""

func _updateButtons():
	
	var module = getSelectedModule()
	if module == null:
		instructionsButtons.setButtons([])
		instructionsButtons2.setButtons([])
		emit_signal("buttons_instructions_changed", [], module)
#		instructionsOrder = []
#		for button in instructionsButtons.get_children():
#			button.setInstructionData(null)
		return
	
	var instructionsData = module.getInstructions()
	instructionsOrder = module.getInstructionsOrder()
	
	var allInstructionsButtons = []
	for instructionOrder in instructionsOrder:
		allInstructionsButtons.append(ALL_INSTRUCTIONS[instructionOrder])
		
	instructionsButtons.setButtons(allInstructionsButtons)
	
	instructionsButtons2.setButtons(ALL_INSTRUCTIONS_FOR_BOTTOM)
	
	instructionsButtons.connectButtons(self, "onInstructionButtonPressed")
	instructionsButtons.connectButtonsHover(self, "onInstructionButtonHover")
	
	instructionsButtons2.connectButtons(self, "onInstructionButtonPressed")
	instructionsButtons2.connectButtonsHover(self, "onInstructionButtonHover")
	
	emit_signal("buttons_instructions_changed", allInstructionsButtons, module)
	
	
	
	
	#	for i in range(instructionsButtons.get_child_count()):
#		var button = instructionsButtons.get_child(i)
#		if i < instructionsOrder.size():
#			button.setInstructionData(ALL_INSTRUCTIONS[instructionsOrder[i]])
#		else:
#			button.setInstructionData(null)
	
#	var thirdFromLastButton = instructionsButtons.get_child(instructionsButtons.get_child_count() - 3)
#	var secondFromLastButton = instructionsButtons.get_child(instructionsButtons.get_child_count() - 2)
#	var lastButton = instructionsButtons.get_child(instructionsButtons.get_child_count() - 1)
#	thirdFromLastButton.setInstructionData(ALL_INSTRUCTIONS['nop'])
#	secondFromLastButton.setInstructionData(ALL_INSTRUCTIONS['node_start'])
#	lastButton.setInstructionData(ALL_INSTRUCTIONS['node_end'])

func getSelectedModule():
	if selectedMachine != null and selectedModuleLocalIdx != null:
		var module = selectedMachine.getModuleFromLocalIdx(selectedModuleLocalIdx)
		return module
	return null

func onMachineRemoved(removedMachine):
	if selectedMachine == removedMachine:
		selectedMachine = null
		selectModule(null, Vector2())

func onModuleRemoved(moduleLocalIdx, machine):
	if machine == selectedMachine and selectedModuleLocalIdx == moduleLocalIdx:
		selectModule(selectedMachine, moduleLocalIdx)
	else:
		editor.updateEditor()

func _ready():
	editor._setup(self)
#	for button in instructionsButtons.get_children():
#		button.connect("pressed", self, "onInstructionButtonPressed", [button.get_index()])
	
	selectModule(null, Vector2(0, 0))
	pic.connect("module_selected", self, "onModuleSelected")
	pic.connect("state_changed", self, "onStateChanged")
		
func onInstructionButtonPressed(buttonData):
	editor.selectInstructionFromToolbar(buttonData)

		
#func onInstructionButtonPressed(buttonId):
#	var button = instructionsButtons.get_child(buttonId)
#	var instructionData = button.getInstructionData()
#	editor.selectInstructionFromToolbar(instructionData)
