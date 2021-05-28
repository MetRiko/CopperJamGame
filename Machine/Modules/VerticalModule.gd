extends ModuleBase

############## Module base - BEGIN

const INSTRUCTIONS = {
	'move_up': {
		'functionName': "moveUp"
	},
	'move_down': {
		'functionName': "moveDown"
	}
}

const INSTRUCTIONS_ORDER = ['move_up', 'move_down']

func _ready():
	_setupNode("dpad_module", self, INSTRUCTIONS, INSTRUCTIONS_ORDER)

##############  Module base - END
	

func moveUp():
	var dir = Vector2(0, -1)
	if getMachine().canMove(dir):
		playAnimationPulse($Sprite)
		getMachine().move(dir)
		getMachine().emit_signal("machine_state_changed")
		
func moveDown():
	var dir = Vector2(0, 1)
	if getMachine().canMove(dir):
		playAnimationPulse($Sprite)
		getMachine().move(dir)
		getMachine().emit_signal("machine_state_changed")
