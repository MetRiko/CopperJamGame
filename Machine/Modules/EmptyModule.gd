extends ModuleBase

############## Module base - BEGIN

const CONNECTIONS = {
	'top_side': true,
	'right_side': true,
	'bottom_side': true,
	'left': true
}

const INSTRUCTIONS = {
}

func _ready():
	_setupNode("empty_module", self, INSTRUCTIONS, CONNECTIONS)
	
##############  Module base - END
