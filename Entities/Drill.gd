extends EntityBase

func _input(event):
	if event.is_action_pressed('num1'):
		rotateC()
	if event.is_action_pressed('num2'):
		moveForward()
	if event.is_action_pressed('num3'):
		rotateCC()

#func _ready():
#	Game.tilemap.get_node("FogOfWar").revealTerrain(currentCellIdx, true)


func _ready():
	Game.beatController.connect("beat", self, "_onBeat")
	
func _onBeat(currentBeat, beats):
	moveForward()

func moveForward():
	var result = .moveForward()
	
	if result.success == false:
		Game.level.removeObstacle(result.targetCellIdx)
		playAnimationPulse($Sprite)
