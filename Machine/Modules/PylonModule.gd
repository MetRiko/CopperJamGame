extends ModuleBase

onready var level = Game.level
onready var tilemap = Game.tilemap

var pylonIdxes  = []
############## Module base - BEGIN

const INSTRUCTIONS = {
}

const INSTRUCTIONS_ORDER = []

func _ready():
	_setupNode("pylon_module", self, INSTRUCTIONS, INSTRUCTIONS_ORDER)

func setupModule(machine, localIdx, rot):
	.setupModule(machine, localIdx, rot)
	pylonIdxes = getPylonIdxes()

func _process(delta):
	update()

func getPylonIdxes():
	var pylonRange = 500
	var positArray = []
	var pylonIdx = .getGlobalIdx()
	for  x in range(pylonRange*2/level.getCellSize().x):
		for  y in range(pylonRange*2/level.getCellSize().y):
			var posit = Vector2(x,y)+pylonIdx - (floor(pylonRange/level.getCellSize().x)*Vector2(1,1))
			if pylonRange > (level.getPosFromCellIdx(posit) - global_position).length():
				positArray.append(posit)
	return positArray

func _draw():
	for idx in pylonIdxes:
		if level.isObstacle(idx) == false && level.getMachineFromIdx(idx) == null: 
			draw_rect(Rect2(-global_position+level.getPosFromCellIdx(idx)+Vector2(level.getCellSize()*0.25),level.getCellSize()*0.5),Color('#fcbe03'),false,0.4,false)
		elif level.isObstacle(idx) == false && level.getMachineFromIdx(idx) != null: 
			draw_rect(Rect2(-global_position+level.getPosFromCellIdx(idx),level.getCellSize()),Color(0,1,1,0.8),false,1.2,false)

#	for idx in calcRange():
#			if level.isObstacle(idx) == false && level.getMachineFromIdx(idx) == null: 
#				draw_rect(Rect2(level.getPosFromCellIdx(idx)+Vector2(level.getCellSize()*0.25),level.getCellSize()*0.5),Color(0,1,1,0.2),false,1,false)
#			elif level.isObstacle(idx) == false && level.getMachineFromIdx(idx) != null: 
#				draw_rect(Rect2(level.getPosFromCellIdx(idx)+Vector2(0,0),level.getCellSize()*1),Color(0,1,1,0.8),false,1,false)

#func calcRange():
#	var positArray = []
#	var playerIdx = level.get_node("Player").currentCellIdx
#	var playerPos = level.getPosFromCellIdx(playerIdx)
#	for  x in range(playerBuildRange*2/level.getCellSize().x):
#		for  y in range(playerBuildRange*2/level.getCellSize().y):
#			var posit = Vector2(x,y)+playerIdx - (floor(playerBuildRange/level.getCellSize().x)*Vector2(1,1))
#			if playerBuildRange > (level.getPosFromCellIdx(posit) - playerPos).length():
#				positArray.append(posit)
#	return positArray
#	positArray.clear()
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
