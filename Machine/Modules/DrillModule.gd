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

func _destroy():
	$Tween.interpolate_property($Particles2D, "modulate:a", 1.0, 0.0, 0.4, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()

func onBeat():
	if drillOn == true and is_instance_valid(_machine):
		_animateDrill()
		var obstacleGlobalIdx = getForwardVector() + getGlobalIdx()
		if level.isObstacle(obstacleGlobalIdx):
			var copperValue = level.getCopperValueOnIdx(obstacleGlobalIdx)
			if copperValue != null:
				level.getCopperValueController().addCopper(copperValue)
			level.removeObstacle(obstacleGlobalIdx)
		else:
			var entity = level.getEntityFromIdx(obstacleGlobalIdx)
			if entity != null:
				entity.doDamage(1.0)
			elif obstacleGlobalIdx == level.getPlayer().getGlobalIdx():
				level.getPlayer().doDamage(1.0)
