extends Node2D

signal player_died

onready var tilemap = $TileMap
onready var entities = $Entities

onready var mapGenerator = tilemap.get_node("MapGenerator")
onready var fogOfWar = tilemap.get_node("FogOfWar")
onready var pathfinding = tilemap.get_node("Pathfinding")
onready var machines = $Machines

#onready var buildController = $Controllers/BuildController

const machineTscn = preload("res://Machine/Machine.tscn")

const ENTITIES = {
	'enemy': preload("res://Entities/Enemy.tscn"),
#	'drill': preload("res://Entities/Drill.tscn"),
#	'generator': preload("res://Entities/Generator.tscn")
}

const tilemapScale = Vector2(0.125, 0.125)
onready var cellSize = tilemap.cell_size * tilemapScale
onready var halfCellSize = cellSize * 0.5

const WALL = [4,5,6,7,8,9,10]
const COPPER = [11,12,13,14]
const DARK_FLOOR = [16, 26, 27, 28]
const FLOOR = [15, 23, 24, 25]

const COPPER_VALUES = [5, 5, 5, 5]

func _process(delta):
	tilemap.material.set_shader_param("cameraPos", Game.camera.global_position / get_viewport().size * get_viewport_transform().get_scale())

	
	if Input.is_action_pressed("x"): #just remove tile
		var cellIdx := getCellIdxFromMousePos()
		var cell : = getCellType(cellIdx)
		if isCellIdObstacle(cell):
			removeObstacle(cellIdx)
	if Input.is_action_just_pressed("z"): #reveal tiles
		var cellIdx := getCellIdxFromMousePos()
		var cell := getCellType(cellIdx)
		if isCellIdDarkFloor(cell):
			fogOfWar.revealTerrain(cellIdx, true)
	
func convertDarkFloorCellIdToFloor(cellId):
	var id = DARK_FLOOR.find(cellId)
	if id != -1:
		return FLOOR[id]
	else:
		return FLOOR[randi()%FLOOR.size()]

func getPlayerInputController():
	return $Controllers/PlayerInputController

func getHoverObjectController():
	return $Controllers/ObjectHoverController

func getCopperValueController():
	return $Controllers/CopperValueController

func getPlayerRangeController():
	return $Controllers/PlayerRangeController
	
#func getAnyCopper():
#	return getRandomInt([11,12,13,14])
#func getAnyWall():
#	return getRandomInt([4,5,6,7,8,9,10])
#func getDarkFloors():
#	return [21, 22]
#func getFloors():
#	return [15, 16]

func moveObjectToDestroyedObjects(node):
	var pos = node.global_position
	node.get_parent().remove_child(node)
	$DestroyedObjects.add_child(node)
#	node.position = Vector2(0.0, 0.0)
	node.global_position = pos

func putFloor(cellIdx):
#	var x = int(cellIdx.x + cellIdx.y + 10000000) % 2
#	tilemap.set_cell(cellIdx.x, cellIdx.y, FLOOR[x])

	var cellId = getCellType(cellIdx)
	var convertedCellId = convertDarkFloorCellIdToFloor(cellId)
	tilemap.set_cell(cellIdx.x, cellIdx.y, convertedCellId)
	pathfinding.astar_add_point(cellIdx)
	
func putDarkFloor(cellIdx):
	var x = int(cellIdx.x + cellIdx.y + 10000000) % 2
	tilemap.set_cell(cellIdx.x, cellIdx.y, DARK_FLOOR[x])

func isCellIdAnyFloor(cellId):
	return isCellIdFloor(cellId) or isCellIdDarkFloor(cellId)

func isCellIdIWall(cellId : int):
	return WALL.has(cellId)
	
func isCellIdCopper(cellId : int):
	return COPPER.has(cellId)
	
func isCellIdFloor(cellId : int):
	return FLOOR.has(cellId)
	
func isCellIdDarkFloor(cellId : int):
	return DARK_FLOOR.has(cellId)
	
func isCellIdObstacle(cellId : int):
	return isCellIdIWall(cellId) or isCellIdCopper(cellId)

func getFirstMachine():
	return $Machines.get_child(0)

func getCellSize():
	return cellSize

func getHalfCellSize():
	return halfCellSize

func justPutObstacle(pos):
	tilemap.set_cell(pos.x, pos.y, WALL[randi()%WALL.size()])

func justRemoveObstacle(pos):
#	updateCell(pos, 1)
	putDarkFloor(pos)

func putObstacle(pos):
	tilemap.set_cell(pos.x, pos.y, WALL[randi()%WALL.size()])
	pathfinding.astar_remove_point(pos)

func removeObstacle(pos):
	
	putDarkFloor(pos)
	fogOfWar.revealTerrain(pos)
	pathfinding.astar_add_point(pos)

func getCopperValueOnIdx(idx : Vector2):
	var cell = getCellType(idx)
	if isCellIdCopper(cell):
		var index = COPPER.find(cell)
		return COPPER_VALUES[index]
	return null

func isObstacle(idx : Vector2):
	return isCellIdObstacle(getCellType(idx))

func isFloorInIdx(idx : Vector2):
	return isCellIdFloor(getCellType(idx))

func isFreeSpace(idx : Vector2):
	return isCellIdAnyFloor(getCellType(idx)) and not isMachineInIdx(idx) and not isAnyEntityInIdx(idx)

func isAnyEntityInIdx(idx : Vector2):
	var entity = getEntityFromIdx(idx)
	if entity != null:
		return true
	return isPlayerIdx(idx)

func isMachineInIdx(idx : Vector2):
	var machine = getMachineFromIdx(idx)
	return machine != null

func getMachines():
	return $Machines.get_children()

func isPlayerIdx(idx : Vector2):
	return idx == $Player.getGlobalIdx()

func getPlayer():
	return $Player

func getEntityFromIdx(idx):
	for entity in $Entities.get_children():
		if entity.getGlobalIdx() == idx:
			return entity
	return null

func getMachineFromIdx(idx : Vector2):
	for machine in $Machines.get_children():
		if machine.isIdxInMachine(idx):
			return machine
	return null

func getModuleFromIdx(idx : Vector2):
	var machine = getMachineFromIdx(idx)
	if machine != null:
		return machine.getModuleFromGlobalIdx(idx)
	return null

var chunksToGenerate = []

func generateChunks(size : int):
	for x in range(size):
		for y in range(size):
			mapGenerator.generateChunk(x - size / 2, y - size / 2)
#			yield(get_tree().create_timer(0.5), "timeout")

func getSquareIdxesFromCenter(idxCenter : Vector2, size : int):
	var idxes = []
	var leftTopIdx = idxCenter - Vector2(int(size * 0.5), int(size * 0.5)) 
	for x in range(size):
		for y in range(size):
			var cellIdx = leftTopIdx + Vector2(x, y)
			idxes.append(cellIdx)
	return idxes

func getCircleIdxesFromCenter(idxCenter : Vector2, radius):
	var idxes = []
	var leftTopIdx = idxCenter - Vector2(floor(radius), floor(radius)) 
	var centerPos = getPosFromCellIdx(idxCenter)
	for x in range(int(radius) * 2 + 1):
		for y in range(int(radius) * 2 + 1):
			var cellIdx = leftTopIdx + Vector2(x, y)
#			var cellPos = getPosFromCellIdx(cellIdx)
			if (cellIdx - idxCenter).length() <= radius:
				idxes.append(cellIdx)
#			print((cellIdx - idxCenter).length())
	return idxes

func getRingIdxesFromCenter(idxCenter : Vector2, minRadius, maxRadius):
	var idxes = []
	var leftTopIdx = idxCenter - Vector2(floor(maxRadius), floor(maxRadius)) 
	var centerPos = getPosFromCellIdx(idxCenter)
	for x in range(int(maxRadius) * 2 + 1):
		for y in range(int(maxRadius) * 2 + 1):
			var cellIdx = leftTopIdx + Vector2(x, y)
#			var cellPos = getPosFromCellIdx(cellIdx)
			var length = (cellIdx - idxCenter).length()
			if length <= maxRadius and length >= minRadius:
				idxes.append(cellIdx)
#			print((cellIdx - idxCenter).length())
	return idxes

func _ready():
	randomize()

	mapGenerator.setSeed(randf())
	generateChunks(12)

	mapGenerator.connect("new_chunk_generated", self, "_onChunkGenerated")
	pathfinding.astar_calculate_full_graph()
	
#	var machine = createNewMachine(Vector2(-1, 2))
#	machine.attachModule('dpad_module', Vector2(0, 0))
#	machine.attachModule('empty_module', Vector2(0, 1))
#	machine.attachModule('empty_module', Vector2(1, 1))
	
	for entity in $Entities.get_children():
		entity.setupPosition(entity.global_position)
	
	var revealCenterIdx = getCellIdxFromPos($Player.global_position)
	for idx in getCircleIdxesFromCenter(revealCenterIdx, 5):
		removeObstacle(idx)
	
	$Player.setupPosition($Player.global_position)
	$Player.connect("player_died", self, "onPlayerDied")
	fogOfWar.revealTerrain($Player.getGlobalIdx(), true)
	$TileMap/EntitySpawner.enableSpawner()
	
	getPlayerRangeController()._calculateRangeIdxes()

func onPlayerDied():
	emit_signal("player_died")

func getCellIdxFromMousePos() -> Vector2:
	return tilemap.world_to_map(get_global_mouse_position() / tilemapScale)# * tilemap.global_scale)

func getCellType(cellIdx) -> int:
	return tilemap.get_cell(cellIdx.x, cellIdx.y)

func getCellIdxFromPos(pos) -> Vector2:
	return tilemap.world_to_map(pos / tilemapScale)
	
func getPosFromCellIdx(cellIdx) -> Vector2:
	return tilemap.map_to_world(cellIdx) * tilemapScale
#	var fixedCellIdx = cellIdx
#
#	fixedCellIdx.x = round(fixedCellIdx.x)
#	fixedCellIdx.y = round(fixedCellIdx.y)
#
#	var finalPos = fixedCellIdx * cellSize
#
#	var pos = tilemap.map_to_world(fixedCellIdx) * tilemapScale
#	pos.x = round(pos.x - 1)
#	pos.y = round(pos.y)
#	return pos

#func _input(event):
#	if event.is_action_pressed("x"): #just remove tile
#		var cellIdx := getCellIdxFromMousePos()
#		var cell : = getCellType(cellIdx)
#		if isCellIdObstacle(cell):
#			removeObstacle(cellIdx)
#	if event.is_action_pressed("z"): #reveal tiles
#		var cellIdx := getCellIdxFromMousePos()
#		var cell := getCellType(cellIdx)
#		if isCellIdDarkFloor(cell):
#			fogOfWar.revealTerrain(cellIdx, true)

func createNewMachine(cellIdx : Vector2):
	var newMachine = machineTscn.instance()
	machines.add_child(newMachine)
	newMachine.setupPos(cellIdx)
	return newMachine

func createEntity(entityId : String, cellIdx : Vector2, revealTerrain = true):
	if ENTITIES.has(entityId):
		var entity = ENTITIES[entityId].instance()
		entities.add_child(entity)
		var pos = getPosFromCellIdx(cellIdx)
		entity.setupPosition(pos)
		fogOfWar.revealTerrain(cellIdx, revealTerrain)
		
func _onChunkGenerated(newCells):
	for cellIdx in newCells:
		var cell : int = getCellType(cellIdx)
		if isCellIdDarkFloor(cell):
			fogOfWar.revealTerrain(cellIdx)
			pathfinding.astar_add_point(cellIdx)
		elif isCellIdFloor(cell):
			pathfinding.astar_add_point(cellIdx)
