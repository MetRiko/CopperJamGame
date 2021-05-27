extends ModuleBase

onready var particlesNode = $Particles/Particles2D

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
	$Particles.rotation_degrees = rot * 90.0
#	$Sprite.global_rotation_degrees = rot * 90.0
#	$Sprite.

func enableTurret():
	enabled = true
	$Sprite.frame = 29 + (_rot % 4)

func disableTurret():
	enabled = false
	$Sprite.frame = 15 + (_rot % 4)

func _destroy():
	$Tween.interpolate_property($Particles, "modulate:a", 1.0, 0.0, 0.4, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()

func onBeat(a, b):
	if isDestroyed() == false and enabled == true and is_instance_valid(_machine):
		shoot()
		playAnimationPulse($Sprite)

func _createSmokeParticles():
	var newParticles = particlesNode.duplicate()
	$Particles.add_child(newParticles)
	newParticles.emitting = true
	yield(get_tree().create_timer(newParticles.lifetime), "timeout")
	newParticles.queue_free()

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
			# $Particles/Particles2D.emitting = true
			_createSmokeParticles()
			return
		
		var enemy = level.getEntityFromIdx(targetIdx)
		if enemy != null:
			enemy.doDamage(1.0)
			# $Particles/Particles2D.emitting = true
			_createSmokeParticles()
			return
