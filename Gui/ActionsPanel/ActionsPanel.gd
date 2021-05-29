extends Control

const actionButtonTscn = preload("res://Gui/ActionsPanel/ActionButton.tscn")

onready var level = Game.level
onready var playerInputController = level.getPlayerInputController()

onready var actionButtons = $Margin/ActionButtons 

var latestSelectedModule = null

var enabled = false

func _ready():
	playerInputController.connect("module_selected", self, "onModuleSelected")
#	playerInputController.connect("state_changed", self, "onStateChanged")
	hidePanel()
	
func showPanel():
	enabled = true
	show()
	
func hidePanel():
	enabled = false
	hide()
	
#func onStateChanged(state):
#	if state == playerInputController.NORMAL_STATE:
#		if latestSelectedModule != null and is_instance_valid(latestSelectedModule) and $Margin/ActionButtons.get_child_count() > 0:
#			showPanel()
#
#	elif state == playerInputController.BUILDING_STATE:
#		hidePanel()
	
var latestMachine = null
	
func onModuleSelected(module):
	latestSelectedModule = module
	
	if module != null:
		if latestMachine != null and is_instance_valid(latestMachine):
			if latestMachine.is_connected("machine_state_changed", self, "onMachineStateChanged"):
				latestMachine.disconnect("machine_state_changed", self, "onMachineStateChanged")
			latestMachine = module.getMachine()
			if not latestMachine.is_connected("machine_state_changed", self, "onMachineStateChanged"):
				latestMachine.connect("machine_state_changed", self, "onMachineStateChanged")
		print(module.getOrderedInstructions())
		_setInstructions(module.getOrderedInstructions())
		showPanel()
#		_updatePanelVisuals()
	else:
		hidePanel()

func onMachineStateChanged():
	_updatePanelVisuals()

func _updatePanelVisuals():
	$Margin.rect_min_size = Vector2()
	$Margin.rect_size = Vector2()
#	rect_global_position = _getPosForPanel(latestSelectedModule.getMachine())

func _setInstructions(instructions):

	for button in actionButtons.get_children():
		button.queue_free()

	for instruction in instructions:
		var button = actionButtonTscn.instance()
		actionButtons.add_child(button)
		button.setInstruction(instruction, latestSelectedModule)

func _getPosForPanel(machine):
	
	var left = 100000
	var right = -100000
	var top = 1000000
	
	for module in machine.getModules():
		var pos = level.getPosFromCellIdx(machine.convertToGlobalIdx(module.localIdx))
		if pos.x < left:
			left = pos.x
		if pos.x > right:
			right = pos.x
		if pos.y < top:
			top = pos.y
	
	var pos = Vector2((right - left + level.getCellSize().x) * 0.5, top - 30.0)
#	pos.x -= get_global_rect().size.x * 0.5
	return pos

#func _process(delta):
#	if enabled == true:
#		if latestSelectedModule != null and is_instance_valid(latestSelectedModule):
#			var machine = latestSelectedModule.getMachine()
#			if is_instance_valid(machine):
#				_updatePanelVisuals()
