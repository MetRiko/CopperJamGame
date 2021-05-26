extends Control

const actionButtonTscn = preload("res://Gui/ActionsPanel/ActionButton.tscn")

onready var level = Game.level
onready var playerInputController = level.getPlayerInputController()

onready var actionButtons = $Margin/ActionButtons 

var latestSelectedModule = null

var enabled = false

func _ready():
	playerInputController.connect("module_selected", self, "onModuleSelected")
	playerInputController.connect("state_changed", self, "onStateChanged")
	hidePanel()
	
func showPanel():
	enabled = true
	show()
	
func hidePanel():
	enabled = false
	hide()
	
func onStateChanged(state):
	if state == playerInputController.NORMAL_STATE:
		if latestSelectedModule != null and is_instance_valid(latestSelectedModule):
			showPanel()
		
	elif state == playerInputController.BUILDING_STATE:
		hidePanel()
	
func onModuleSelected(module):
	latestSelectedModule = module
	
	if module != null and playerInputController.isNormalState():
		_setInstructions(module.getOrderedInstructions())
		showPanel()
	else:
		hidePanel()

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
	
	var pos = Vector2((right - left + level.getCellSize().x) * 0.5, top)
	return pos

func _process(delta):
	if enabled == true:
		if latestSelectedModule != null and is_instance_valid(latestSelectedModule):
			$Margin.rect_min_size = Vector2()
			$Margin.rect_size = Vector2()
			rect_global_position = _getPosForPanel(latestSelectedModule.getMachine())
