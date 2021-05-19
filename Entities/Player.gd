extends EntityBase

var moveTargetIdx = null

var step = 0

func _input(event):
	if event.is_action_pressed('LMB'):
		
		var targetCellIdx = tilemap.world_to_map(get_global_mouse_position())
		var cell = tilemap.get_cell(targetCellIdx.x, targetCellIdx.y)
		if cell == 1 || cell == 2:
			moveTargetIdx = targetCellIdx
#			var pointPath = tilemap.get_node('Pathfinding').pathfind(currentCellIdx, tilemap.world_to_map(get_global_mouse_position()))
		else:
			moveTargetIdx = null

func _ready():
	Game.beatController.connect("quarter_beat", self, "_onQuarterBeat")
	Game.beatController.connect("beat", self, "_onBeat")
	
func _playRotateAnimation():
	step += 1
	if step % 2 == 0:
		$Tween.interpolate_property($Sprite, "global_rotation_degrees", 0, 30, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
		$Tween.start()
		$Tween.interpolate_property($Sprite, "global_rotation_degrees", 30, 0, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
		$Tween.start()
	else:
		$Tween.interpolate_property($Sprite, "global_rotation_degrees", 0, -30, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
		$Tween.start()
		$Tween.interpolate_property($Sprite, "global_rotation_degrees", -30, 0, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
		$Tween.start()
	
func _onBeat(a, b):
	$Anim.play("Move", -1, 5.0)
	
func playAnimation():
	pass
	
func _onQuarterBeat():
	if moveTargetIdx != null:
		var pointPath = tilemap.get_node('Pathfinding').pathfind(currentCellIdx, moveTargetIdx)
		if pointPath.size() < 2:
			moveTargetIdx = null
		else:
			var point =  pointPath[1] - pointPath[0]
			move(Vector2(point.x, point.y))
			_playRotateAnimation()

#func _ready():
#	Game.tilemap.get_node("FogOfWar").revealTerrain(currentCellIdx, true)

func moveForward():
	var result = .moveForward()
	
	if result.success == false:
#		Game.tilemap.set_cell(result.targetCellIdx.x, result.targetCellIdx.y, 1)
#		Game.tilemap.get_node("FogOfWar").revealTerrain(result.targetCellIdx)
		playAnimation()
