extends ModuleBase

############## Module base - BEGIN

const INSTRUCTIONS = {
	'move_left': {
		'functionName': "moveLeft"
	},
	'move_right': {
		'functionName': "moveRight"
	},
	'move_up': {
		'functionName': "moveUp"
	},
	'move_down': {
		'functionName': "moveDown"
	}
}

const INSTRUCTIONS_ORDER = ['move_left', 'move_right', 'move_up', 'move_down']

func _ready():
	_setupNode("dpad_module", self, INSTRUCTIONS, INSTRUCTIONS_ORDER)

##############  Module base - END
	
func moveLeft():
	var dir = Vector2(-1, 0)
	if getMachine().canMove(dir):
		playAnimationPulse($Sprite)
		playAnimationRotateC($Sprite)
		getMachine().move(dir)
	
func moveRight():
	var dir = Vector2(1, 0)
	if getMachine().canMove(dir):
		getMachine().move(dir)

func moveUp():
	var dir = Vector2(0, -1)
	if getMachine().canMove(dir):
		getMachine().move(dir)
		
func moveDown():
	var dir = Vector2(0, 1)
	if getMachine().canMove(dir):
		getMachine().move(dir)
