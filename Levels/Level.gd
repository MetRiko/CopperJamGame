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

#func updateCell(pos, state):
#	tilemap.set_cell(pos.x, pos.y, state)

func _ready():
	for x in range(5):
		for y in range(5):
			mapGenerator.generateChunk(x - 2, y - 2)
			
	mapGenerator.connect("new_chunk_generated", self, "_onChunkGenerated")
	pathfinding.astar_calculate_full_graph()

func _input(event):
	if event.is_action_pressed("num4"):
		var cellIdx = tilemap.world_to_map(get_global_mouse_position())
		createEntity('drill', cellIdx)
		fogOfWar.revealTerrain(cellIdx, true)
	if event.is_action_pressed("num5"):
		var cellIdx = tilemap.world_to_map(get_global_mouse_position())
		createEntity('generator', cellIdx)
		fogOfWar.revealTerrain(cellIdx, true)
		
	if event.is_action_pressed("x"): #just remove tile
		var cellIdx : Vector2 = tilemap.world_to_map(get_global_mouse_position())
		var cell : int = tilemap.get_cell(cellIdx.x, cellIdx.y)
		if cell == 0:
			removeObstacle(cellIdx)
	if event.is_action_pressed("z"): #reveal tiles
		var cellIdx : Vector2 = tilemap.world_to_map(get_global_mouse_position())
		var cell : int = tilemap.get_cell(cellIdx.x, cellIdx.y)
		if cell == 1:
			fogOfWar.revealTerrain(cellIdx, true)

func createEntity(entityId : String, cellIdx : Vector2):
	if ENTITIES.has(entityId):
		var entity = ENTITIES[entityId].instance()
		entity.global_position = tilemap.map_to_world(cellIdx)
		entities.add_child(entity)
		
func _onChunkGenerated(newCells):
	for cell in newCells:
		if cell == 1 or cell == 2:
			pathfinding.astar_add_point(cell)
