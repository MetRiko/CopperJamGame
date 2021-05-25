extends EntityBase

signal player_died

var moveTargetIdx = null

var step = 0

onready var healthController = $ModuleHealthController

var healingBeat = 0

func autoMoveToIdx(idx):
	var cell = level.getCellType(idx)
	if level.isCellIdAnyFloor(cell) and level.getMachineFromIdx(idx) == null:
		moveTargetIdx = idx
	else:
		moveTargetIdx = null

func _ready():
	Game.beatController.connect("quarter_beat", self, "_onQuarterBeat")
	Game.beatController.connect("beat", self, "_onBeat")
	healthController.connect("no_health", self, "onNoHealth")
	
func onNoHealth():
	$Tween.interpolate_property($Sprite, 'global_scale', $Sprite.global_scale, Vector2(0.125 * 1.4, 0.125 * 1.4), 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	$Tween.interpolate_property($Sprite, 'modulate', $Sprite.modulate, Color(0.0, 0.0, 0.0, 1.0), 0.4, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Tween.interpolate_property($Sprite, 'modulate', $Sprite.modulate, Color(0.0, 0.0, 0.0, 0.0), 0.6, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	$Tween.interpolate_property($Sprite, 'global_scale', $Sprite.global_scale, Vector2(0.0, 0.0), 0.6, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	visible = false
	print("Player is dead")
	emit_signal("player_died")
#	queue_free()
	
func doDamage(value):
	healthController.doDamage(value)
	playAnimationPulse($Sprite)
	
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
	healingBeat = (healingBeat + 1) % 5
	if healingBeat == 0 and not healthController.isFullHp():
		healthController.doDamage(-1.0)
#	$Anim.play("Move", -1, 5.0)
	playAnimationPulse($Sprite)
	
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
		
func playAnimationAttack(offset : Vector2):
	playAnimationPulse($Sprite)
	
func move(offset : Vector2):
	
	var oldCellIdx = currentCellIdx
	var targetCellIdx = currentCellIdx + offset
	var targetCell = level.getCellType(targetCellIdx)
	
	if level.isCellIdObstacle(targetCell):
		return { success = false, targetCellIdx = targetCellIdx, targetCell = targetCell, action = "obstacle"}
	
	var machine = level.getMachineFromIdx(targetCellIdx)
	if machine != null:
		return { success = false, targetCellIdx = targetCellIdx, targetCell = targetCell, action = "module"}

	var enemy = level.getEntityFromIdx(targetCellIdx)
	if enemy != null:
		playAnimationAttack(offset)
		enemy.doDamage(1.0)
		return { success = false, targetCellIdx = targetCellIdx, targetCell = targetCell, action = "enemy_attacked"}
	
	currentCellIdx += offset
	var targetPos = getCellPos(currentCellIdx)
	$Tween.interpolate_property(self, "global_position", global_position, targetPos, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	playAnimationPulse($Sprite)
	
	return {
		success = true, 
		targetCellidx = targetCellIdx, 
		targetCell = targetCell,
		action = "moved"
	}
	
	emit_signal("moved", oldCellIdx, targetCellIdx) #from -> to

