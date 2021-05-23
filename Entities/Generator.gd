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
	playAnimationPulse($Sprite)

func moveForward():
	var result = .moveForward()
	
	if result.success == false:
		Game.tilemap.set_cell(result.targetCellIdx.x, result.targetCellIdx.y, 1)
		Game.tilemap.get_node("FogOfWar").revealTerrain(result.targetCellIdx)
		playAnimationPulse($Sprite)
