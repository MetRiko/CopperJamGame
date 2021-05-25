extends EntityBase

onready var healthController = $HealthController

onready var pathfinding = tilemap.get_node('Pathfinding')

var isAlive = true

func _input(event):
	
	if event.is_action_pressed('i'):
		autoMove()
		
#	if event.is_action_pressed("lmb"):
#		print(level.getCellIdxFromMousePos())
	
#	if event.is_action_pressed('i'):
#		var pointPath = pathfinding.pathfind(currentCellIdx, level.getCellIdxFromMousePos())
#		if pointPath.size() >= 2:
#			var point =  pointPath[1] - pointPath[0]
#			move(Vector2(point.x, point.y))
#	if event.is_action_pressed('LMB'):
#		doDamage(1.0)

func setupPosition(pos):
	.setupPosition(pos)

	var bestPath = calculateBestPath()
	
	if bestPath.empty():
		queue_free()

func autoMove():
	var bestPath = calculateBestPath()
	
	if bestPath.empty():
		queue_free()
	
	if bestPath.size() >= 2:
		var vec = bestPath[1] - bestPath[0]
		move(vec)

func calculateBestPath():
	var machines = level.getMachines()
	
	var machinesRandomIdxes = [level.getPlayer().getGlobalIdx()]
	for machine in machines:
		var modules = machine.getModules()
		if modules.size() > 0:
			var randomModule = modules.values()[randi()%modules.size()]
			var randomIdx = machine.convertToGlobalIdx(randomModule.localIdx)
			machinesRandomIdxes.append(randomIdx)
	
	var paths = []
	for moduleIdx in machinesRandomIdxes:
		var path = pathfinding.pathfind(currentCellIdx, moduleIdx)	
		paths.append(path)
	
	var bestPath = paths[0]
	for path in paths:
		if path.size() < bestPath.size() or bestPath.size() == 0:
			bestPath = path
	
	var bestPaths = []
	for path in paths:
		if path.size() == bestPath.size():
			bestPaths.append(path)
	
	return bestPaths[randi() % bestPaths.size()]
	

func _ready():
	randomize()
	healthController.connect("no_health", self, "onNoHealth")
	Game.beatController.connect("beat", self, "onBeat")
#	Game.tilemap.get_node("FogOfWar").revealTerrain(currentCellIdx, true)

func onBeat(a, b):
	autoMove()

func onNoHealth():
	isAlive = false
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
	queue_free()

func doDamage(value):
	healthController.doDamage(value)
	playAnimationPulse($Sprite)

func moveForward():
	var result = .moveForward()
	
	if result.success == false:
#		Game.tilemap.set_cell(result.targetCellIdx.x, result.targetCellIdx.y, 1)
#		Game.tilemap.get_node("FogOfWar").revealTerrain(result.targetCellIdx)
		playAnimationPulse($Sprite)
		
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
		machine.damageModuleOnLocalIdx(machine.convertToLocalIdx(targetCellIdx), 1.0)
		return { success = false, targetCellIdx = targetCellIdx, targetCell = targetCell, action = "module_attacked"}
	
	if level.isPlayerIdx(targetCellIdx):
		level.getPlayer().doDamage(1.0)
		playAnimationAttack(offset)
		return { success = false, targetCellIdx = targetCellIdx, targetCell = targetCell, action = "player_attacked"}
	
	if level.getEntityFromIdx(targetCellIdx) != null:
		playAnimationPulse($Sprite)
		return { success = false, targetCellIdx = targetCellIdx, targetCell = targetCell, action = "another_enemy"}
	
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
