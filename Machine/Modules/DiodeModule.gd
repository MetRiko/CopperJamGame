extends ModuleBase

############## Module base - BEGIN

const INSTRUCTIONS = {
	'turn_on_diode': {
		'functionName': "turnOnDiode"
	},
	'turn_off_diode': {
		'functionName': "turnOffDiode"
	},
	'is_diode_on': {
		'conditionFunctionName': 'isDiodeOn'
	},
	'is_diode_off': {
		'conditionFunctionName': 'isDiodeOff'
	}
}

const INSTRUCTIONS_ORDER = ['turn_on_diode', 'turn_off_diode', 'is_diode_on', 'is_diode_off']

func _ready():
	_setupNode("diode_module", self, INSTRUCTIONS, INSTRUCTIONS_ORDER)

##############  Module base - END
	
var isDiodeOn = false

onready var defaultFrame = $Sprite.frame

func turnOnDiode():
	$Sprite.frame = defaultFrame - 1
	isDiodeOn = true

func turnOffDiode():
	$Sprite.frame = defaultFrame
	isDiodeOn = false
	
func isDiodeOn():
	return isDiodeOn == true
	
func isDiodeOff():
	return isDiodeOn == false
