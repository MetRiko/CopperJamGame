extends ModuleBase

onready var level = Game.level
onready var tilemap = Game.tilemap
############## Module base - BEGIN

const INSTRUCTIONS = {
	'turn_on_turret': {
		'functionName': "enableTurret"
	},
	'turn_off_turret': {
		'functionName': "disableTurret"
	}
}

var beatController = null

var enabled = false

const INSTRUCTIONS_ORDER = ['turn_on_turret', 'turn_off_turret']

func _ready():
	_setupNode("turret_module", self, INSTRUCTIONS, INSTRUCTIONS_ORDER)

func setupModule(machine, localIdx, rot):
	.setupModule(machine, localIdx, rot)
	beatController = Game.beatController
	beatController.connect("beat", self, "onBeat")
	$Sprite.frame = 15 + (rot % 4)
	$Node2D.rotation_degrees = rot * 90.0
#	$Sprite.global_rotation_degrees = rot * 90.0
#	$Sprite.

func enableTurret():
	enabled = true
	$Sprite.frame = 29 + (_rot % 4)

func disableTurret():
	enabled = false
	$Sprite.frame = 15 + (_rot % 4)

func onBeat(a, b):
	if enabled == true and is_instance_valid(_machine):
		shoot()
		playAnimationPulse($Sprite)

func shoot():
	var offset = getForwardVector()
	
	var shootingRange = 6
	
	var startIdx = getGlobalIdx()
	var targetIdx = startIdx 
	
	for i in range(shootingRange):
		targetIdx += offset
		
		if level.isObstacle(targetIdx):
			return
		
		var player = level.getPlayer()
		if player.getGlobalIdx() == targetIdx:
			player.doDamage(1.0)
			$Node2D/Particles2D.emitting = true
			return
		
		var enemy = level.getEntityFromIdx(targetIdx)
		if enemy != null:
			enemy.doDamage(1.0)
			$Node2D/Particles2D.emitting = true
			return
