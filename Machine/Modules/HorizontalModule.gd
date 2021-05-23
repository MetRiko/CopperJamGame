extends ModuleBase

############## Module base - BEGIN

const INSTRUCTIONS = {
	'move_left': {
		'functionName': "moveLeft"
	},
	'move_right': {
		'functionName': "moveRight"
	}
}

const INSTRUCTIONS_ORDER = ['move_left', 'move_right']

func _ready():
	_setupNode("dpad_module", self, INSTRUCTIONS, INSTRUCTIONS_ORDER)

##############  Module base - END
	
func moveLeft():
	var dir = Vector2(-1, 0)
	if getMachine().canMove(dir):
		playAnimationPulse($Sprite)
#		playAnimationRotateC($Sprite)
		getMachine().move(dir)
	
func moveRight():
	var dir = Vector2(1, 0)
	if getMachine().canMove(dir):
		playAnimationPulse($Sprite)
		getMachine().move(dir)

