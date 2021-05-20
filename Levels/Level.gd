extends Node2D

onready var tilemap = $TileMap
onready var entities = $Entities

onready var mapGenerator = tilemap.get_node("MapGenerator")
onready var fogOfWar = tilemap.get_node("FogOfWar")
onready var pathfinding = tilemap.get_node("Pathfinding")

const ENTITIES = {
	'drill': preload("res://Entities/Drill.tscn"),
	'generator': preload("res://Entities/Generator.tscn")
}

func justPutObstacle(pos):
	tilemap.set_cell(pos.x, pos.y, 0)

func justRemoveObstacle(pos):
#	updateCell(pos, 1)
	tilemap.set_cell(pos.x, pos.y, 1)
	
func putObstacle(pos):
	tilemap.set_cell(pos.x, pos.y, 0)
	pathfinding.astar_remove_point(pos)

func removeObstacle(pos):
#	updateCell(pos, 1)
	tilemap.set_cell(pos.x, pos.y, 1)
	fogOfWar.revealTerrain(pos)
	pathfinding.astar_add_point(pos)

func isObstacle(idx : Vector2):
	return tilemap.get_cell(idx.x, idx.y) == 0
#func updateCell(pos, state):
#	tilemap.set_cell(pos.x, pos.y, state)

func _ready():
	for x in range(5):
		for y in range(5):
			mapGenerator.generateChunk(x - 2, y - 2)
			
	mapGenerator.connect("new_chunk_generated", self, "_onChunkGenerated")
	pathfinding.astar_calculate_full_graph()
	
	var machine = $Entities/Machine
	machine.setupPos(Vector2(-1, 2))
	machine.attachModule('dpad_module', Vector2(0, 0))
	machine.attachModule('empty_module', Vector2(0, 1))
	machine.attachModule('empty_module', Vector2(1, 1))

func getCellIdxFromMousePos() -> Vector2:
	return tilemap.world_to_map(get_global_mouse_position())

func getCellType(cellIdx) -> int:
	return tilemap.get_cell(cellIdx.x, cellIdx.y)

func getCellIdxFromPos(pos) -> Vector2:
	return tilemap.world_to_map(pos)
	
func getPosFromCellIdx(cellIdx) -> Vector2:
	return tilemap.map_to_world(cellIdx)

func _input(event):
	if event.is_action_pressed("num4"):
		createEntity('drill', getCellIdxFromMousePos())
	if event.is_action_pressed("num5"):
		createEntity('generator', getCellIdxFromMousePos())
		
	if event.is_action_pressed("x"): #just remove tile
		var cellIdx := getCellIdxFromMousePos()
		var cell : = getCellType(cellIdx)
		if cell == 0:
			removeObstacle(cellIdx)
	if event.is_action_pressed("z"): #reveal tiles
		var cellIdx := getCellIdxFromMousePos()
		var cell := getCellType(cellIdx)
		if cell == 1:
			fogOfWar.revealTerrain(cellIdx, true)

func createEntity(entityId : String, cellIdx : Vector2, revealTerrain = true):
	if ENTITIES.has(entityId):
		var entity = ENTITIES[entityId].instance()
		entity.global_position = tilemap.map_to_world(cellIdx)
		entities.add_child(entity)
		fogOfWar.revealTerrain(cellIdx, revealTerrain)
		
func _onChunkGenerated(newCells):
	for cellIdx in newCells:
		var cell : int = getCellType(cellIdx)
		if cell == 1:
			fogOfWar.revealTerrain(cellIdx)
			pathfinding.astar_add_point(cellIdx)
		elif cell == 2:
			pathfinding.astar_add_point(cellIdx)
