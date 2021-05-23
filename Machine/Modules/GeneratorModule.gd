extends ModuleBase

onready var menu = Game.menu
onready var gui = Game.gui

var generatorHp := int(1)
############## Module base - BEGIN

const INSTRUCTIONS = {
	'end_game': {
		'functionName': "endGame"
}
}


const INSTRUCTIONS_ORDER = []

func _ready():
	_setupNode("generator_module", self, INSTRUCTIONS, INSTRUCTIONS_ORDER)
	
##############  Module base - END

func end_game():
	if generatorHp <= 0:
		menu.visible = true
		gui.visible = false
