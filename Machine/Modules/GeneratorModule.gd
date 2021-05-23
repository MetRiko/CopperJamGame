extends ModuleBase

############## Module base - BEGIN

const INSTRUCTIONS = {
}

const INSTRUCTIONS_ORDER = []

func _ready():
	_setupNode("generator_module", self, INSTRUCTIONS, INSTRUCTIONS_ORDER)
	
##############  Module base - END
