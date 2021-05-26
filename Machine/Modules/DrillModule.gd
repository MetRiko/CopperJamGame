extends ModuleBase

############## Module base - BEGIN

const INSTRUCTIONS = {
	'turn_on_drill': {
		'functionName': "turnOnDrill"
	},
	'turn_off_drill': {
		'functionName': "turnOffDrill"
	}
}

const INSTRUCTIONS_ORDER = ['turn_on_drill', 'turn_off_drill']

func _ready():
	_setupNode("drill_module", self, INSTRUCTIONS, INSTRUCTIONS_ORDER)
	$Particles2D.emitting = false

##############  Module base - END
onready var gui = Game.gui
onready var level = Game.level

var drillOn = false

var beatController = null

func setupModule(machine, localIdx, rot):
	.setupModule(machine, localIdx, rot)
	beatController = Game.beatController
	beatController.connect("beat", self, "onBeat")
	$Sprite.global_rotation_degrees = rot * 90.0

func _animateDrill():
	playAnimationPulse($Sprite)

func turnOnDrill():
	drillOn = true
	$Particles2D.emitting = true

func turnOffDrill():
	drillOn = false
	$Particles2D.emitting = false

func onBeat(a, b):
	if drillOn == true:
		_animateDrill()
		var obstacleGlobalIdx = getForwardVector() + getGlobalIdx()
		if level.isObstacle(obstacleGlobalIdx):
			var copperValue = level.getCopperValueOnIdx(obstacleGlobalIdx)
			# if copperValue != null:
				# gui.addCopper(copperValue) TODO
			level.removeObstacle(obstacleGlobalIdx)
		else:
			var entity = level.getEntityFromIdx(obstacleGlobalIdx)
			if entity != null:
				entity.doDamage(1.0)
			
			
