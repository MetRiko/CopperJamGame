extends ModuleBase

############## Module base - BEGIN

const CONNECTIONS = {
	'top_side': true,
	'right_side': true,
	'bottom_side': true,
	'left': true
}

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

func _ready():
	_setupNode("dpad_module", self, INSTRUCTIONS, CONNECTIONS)

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
