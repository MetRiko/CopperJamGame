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

func _ready():
	_setupNode(self, INSTRUCTIONS)

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
