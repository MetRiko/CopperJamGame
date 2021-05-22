extends ModuleBase

onready var level = Game.level
onready var tilemap = Game.tilemap
############## Module base - BEGIN

const INSTRUCTIONS = {
	'shoot': {
		'functionName': "shoot"
	}
}

const INSTRUCTIONS_ORDER = ['shoot']

func _ready():
	_setupNode("turret_module", self, INSTRUCTIONS, INSTRUCTIONS_ORDER)

func shoot(enemyIdx):
	var shootingRange = 6
	var shootingRangeIdx = []
	var forwardVector = getForwardVector()
	var firstIdx = getGlobalIdx()
	var entityDetected = level.getEntityFromIdx()
	
	for i in range(shootingRange):
		shootingRangeIdx.append(level.getCellIdxFromPos(firstIdx))
		firstIdx += forwardVector
		
		if level.isObstacle() == true:
			return
		if  entityDetected != null:
			level.dealDamage()


##############  Module base - END
	
#func moveLeft():
#	var dir = Vector2(-1, 0)
#	if getMachine().canMove(dir):
#		playAnimationPulse($Sprite)
#		playAnimationRotateC($Sprite)
#		getMachine().move(dir)
#
#func moveRight():
#	var dir = Vector2(1, 0)
#	if getMachine().canMove(dir):
#		getMachine().move(dir)
#
#func moveUp():
#	var dir = Vector2(0, -1)
#	if getMachine().canMove(dir):
#		getMachine().move(dir)
#
#func moveDown():
#	var dir = Vector2(0, 1)
#	if getMachine().canMove(dir):
#		getMachine().move(dir)
