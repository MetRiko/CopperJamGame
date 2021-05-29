extends ModuleBase

onready var particlesNode = $Particles/Particles2D
onready var passiveParticlesNode = $Particles/Particles2DOn

onready var level = Game.level
onready var tilemap = Game.tilemap

############## Module base - BEGIN

const INSTRUCTIONS = {
	'turn_on_tesla': {
		'functionName': "enableTesla"
	},
	'turn_off_tesla': {
		'functionName': "disableTesla"
	}
}

var beatController = null

var enabled = false

const INSTRUCTIONS_ORDER = ['turn_on_tesla', 'turn_off_tesla']

func _ready():
	_setupNode("tesla_module", self, INSTRUCTIONS, INSTRUCTIONS_ORDER)

func setupModule(machine, localIdx, rot):
	.setupModule(machine, localIdx, rot)
	beatController = Game.beatController
	beatController.connect("beat", self, "onBeat")
#	$Sprite.frame = 21
#	$Sprite.global_rotation_degrees = rot * 90.0
#	$Sprite.

func enableTesla():
	enabled = true
	passiveParticlesNode.emitting = true

func disableTesla():
	enabled = false
	passiveParticlesNode.emitting = false

func _destroy():
	$Tween.interpolate_property($Particles, "modulate:a", 1.0, 0.0, 0.4, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()

func onBeat():
	if isDestroyed() == false and enabled == true and is_instance_valid(_machine):
		pulse()
		playAnimationPulse($Sprite)

func _createLightningParticles():
	var newParticles = particlesNode.duplicate()
	$Particles.add_child(newParticles)
	newParticles.emitting = true
	yield(get_tree().create_timer(newParticles.lifetime), "timeout")
	newParticles.queue_free()

func pulse():
	
	var shootingRange = 6
	
	var startIdx = getGlobalIdx()
	var targetIdx = startIdx 
	var ring = level.getRingIdxesFromCenter(targetIdx, 0, shootingRange)
	
	for idx in ring:
		var player = level.getPlayer()
		if player.getGlobalIdx() == idx:
			player.doDamage(1.0)
			# $Particles/Particles2D.emitting = true
			_createLightningParticles()
		
		var enemy = level.getEntityFromIdx(idx)
		if enemy != null:
			enemy.doDamage(1.0)
			# $Particles/Particles2D.emitting = true
			_createLightningParticles()

