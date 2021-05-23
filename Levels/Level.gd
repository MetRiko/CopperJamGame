extends Node2D

onready var tilemap = $TileMap
onready var entities = $Entities

onready var mapGenerator = tilemap.get_node("MapGenerator")
onready var fogOfWar = tilemap.get_node("FogOfWar")
onready var pathfinding = tilemap.get_node("Pathfinding")
onready var machines = $Machines

const machineTscn = preload("res://Machine/Machine.tscn")

const ENTITIES = {
	'drill': preload("res://Entities/Drill.tscn"),
	'generator': preload("res://Entities/Generator.tscn")
}

const tilemapScale = Vector2(0.125, 0.125)
onready var cellSize = tilemap.cell_size * tilemapScale
onready var halfCellSize = cellSize * 0.5

const WALL = [4,5,6,7,8,9,10]
const COPPER = [11,12,13,14]
const DARK_FLOOR = [21, 22]
const FLOOR = [15, 16]

#func 


#func getAnyCopper():
#	return getRandomInt([11,12,13,14])
#func getAnyWall():
#	return getRandomInt([4,5,6,7,8,9,10])
#func getDarkFloors():
#	return [21, 22]
#func getFloors():
#	return [15, 16]

func _putFloor(cellIdx):
	var x = int(cellIdx.x + cellIdx.y + 10000000) % 2
	tilemap.set_cell(cellIdx.x, cellIdx.y, FLOOR[x])
	
func _putDarkFloor(cellIdx):
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
	tilemap.set_cell(pos.x, pos.y, 0)

func justRemoveObstacle(pos):
#	updateCell(pos, 1)
	tilemap.set_cell(pos.x, pos.y, 1)

func putObstacle(pos):
	tilemap.set_cell(pos.x, pos.y, 0)
	pathfinding.astar_remove_point(pos)

func removeObstacle(pos):
	
	_putDarkFloor(pos)
	fogOfWar.revealTerrain(pos)
	pathfinding.astar_add_point(pos)

func isObstacle(idx : Vector2):
	return isCellIdObstacle(getCellType(idx))

func getMachineFromIdx(idx : Vector2):
	for machine in $Machines.get_children():
		if machine.isIdxInMachine(idx):
			return machine
	return null

func _ready():
	for x in range(5):
		for y in range(5):
			mapGenerator.generateChunk(x - 2, y - 2)

	mapGenerator.connect("new_chunk_generated", self, "_onChunkGenerated")
	pathfinding.astar_calculate_full_graph()
	
	var machine = createNewMachine(Vector2(-1, 2))
	machine.attachModule('dpad_module', Vector2(0, 0))
	machine.attachModule('empty_module', Vector2(0, 1))
	machine.attachModule('empty_module', Vector2(1, 1))
	
	for entity in $Entities.get_children():
		entity.setupPosition(entity.global_position)
	
	$Player.setupPosition($Player.global_position)
	

func getCellIdxFromMousePos() -> Vector2:
	return tilemap.world_to_map(get_global_mouse_position() / tilemapScale)# * tilemap.global_scale)

func getCellType(cellIdx) -> int:
	return tilemap.get_cell(cellIdx.x, cellIdx.y)

func getCellIdxFromPos(pos) -> Vector2:
	return tilemap.world_to_map(pos / tilemapScale)
	
func getPosFromCellIdx(cellIdx) -> Vector2:
	var fixedCellIdx = cellIdx

	fixedCellIdx.x = round(fixedCellIdx.x)
	fixedCellIdx.y = round(fixedCellIdx.y)
	
	var finalPos = fixedCellIdx * cellSize
	
	var pos = tilemap.map_to_world(fixedCellIdx) * tilemapScale
	pos.x = round(pos.x - 1)
	pos.y = round(pos.y)
	return pos

func _input(event):
	if event.is_action_pressed("num4"):
		createEntity('drill', getCellIdxFromMousePos())
	if event.is_action_pressed("num5"):
		createEntity('generator', getCellIdxFromMousePos())

	if event.is_action_pressed("x"): #just remove tile
		var cellIdx := getCellIdxFromMousePos()
		var cell : = getCellType(cellIdx)
		if isCellIdObstacle(cell):
			removeObstacle(cellIdx)
	if event.is_action_pressed("z"): #reveal tiles
		var cellIdx := getCellIdxFromMousePos()
		var cell := getCellType(cellIdx)
		if isCellIdDarkFloor(cell):
			fogOfWar.revealTerrain(cellIdx, true)

func createNewMachine(cellIdx : Vector2):
	var newMachine = machineTscn.instance()
	machines.add_child(newMachine)
	newMachine.setupPos(cellIdx)	
	return newMachine

func createEntity(entityId : String, cellIdx : Vector2, revealTerrain = true):
	if ENTITIES.has(entityId):
		var entity = ENTITIES[entityId].instance()
		entities.add_child(entity)
		entity.global_position = getPosFromCellIdx(cellIdx)
		fogOfWar.revealTerrain(cellIdx, revealTerrain)
		
func _onChunkGenerated(newCells):
	for cellIdx in newCells:
		var cell : int = getCellType(cellIdx)
		if isCellIdDarkFloor(cell):
			fogOfWar.revealTerrain(cellIdx)
			pathfinding.astar_add_point(cellIdx)
		elif isCellIdFloor(cell):
			pathfinding.astar_add_point(cellIdx)
