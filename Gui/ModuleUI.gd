extends Control

onready var nodeEditor = Game.nodeEditor

onready var instructionsButtons = $InstructionsButtons

var currentModule = null

var buttonsCount = 0

var sizeChanged = false

# Called when the node enters the scene tree for the first time.
func _ready():
	nodeEditor.connect("buttons_instructions_changed", self, "onButtonsInstructionsChange")
	
#func _process(delta):
#	if sizeChanged == true:
#		_backVisualUpdate()
#		sizeChanged = false
	
#func _backVisualUpdate():
#
#	var firstButton = $InstructionsButtons.get_child(0)
#	var lastButton = $InstructionsButtons.get_child($InstructionsButtons.get_child_count()-1)
#
#	var size =  (lastButton.get_global_rect().position - (firstButton.get_global_rect().position + lastButton.rect_size)) * 2.0
#
#	$Back.rect_global_position = firstButton.rect_global_position
#	$Back.rect_size = size
	
#	var pos = rect_global_position
#	var width = (lastButton.get_global_rect().position - (firstButton.get_global_rect().position + lastButton.rect_size)) * 2.0
	
#	var size = $InstructionsButtons.rect_size * rect_scale
#	$Back.rect_size = Vector2(buttonsCount * 51.2 * 0.25 * buttonsCount + 51.2 * 0.5, 51.2 + 51.2 * 0.125 )
#	$Back.rect_min_size = Vector2(1000, 40.0)
#	$Back.rect_min_size = firstButton.rect_size + Vector2($InstructionsButtons.get_constant("separation") * $InstructionsButtons.get_child_count(), 0.0)
#	$Back.rect_size = firstButton.rect_size + Vector2($InstructionsButtons.get_constant("separation") * $InstructionsButtons.get_child_count(), 0.0)
#	$Back.rect_position = pos - Vector2(51.2 * 0.125 + buttonsCount * 51.2 * 0.5, 51.2 + 0.125 * 51.2)
	
func _process(delta):
	if is_instance_valid(currentModule):
		rect_global_position = Game.level.getPosFromCellIdx(currentModule.getGlobalIdx()) + Vector2(32.0 * 0.5, -32.0) # - Vector2(859.0 * 0.125 * 0.5 - 32.0 * 0.5, -10.0)
		
	
func onButtonsInstructionsChange(newButtonsInstructions, module):
	instructionsButtons.setButtons(newButtonsInstructions)
	
	instructionsButtons.connectButtons(self, "onButtonClick")
	currentModule = module
	if module == null:
		visible = false
	else:
		visible = true
#		rect_global_position = Vector2(10, 10)
#		rect_global_position = module.global_position - Vector2(859.0 * 0.125 * 0.5 - 32.0 * 0.5, -10.0)
		buttonsCount = newButtonsInstructions.size()
	
#	if newButtonsInstructions.size() > 0:
#		sizeChanged = true
#		_backVisualUpdate()

func onButtonClick(buttonData):
	if currentModule != null:
		currentModule.callInstruction(buttonData.instructionId)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
