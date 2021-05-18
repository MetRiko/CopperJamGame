extends Node2D

onready var tilemap = $TileMap
onready var entities = $Entities

const ENTITIES = {
	'drill': preload("res://Entities/Drill.tscn")
}

func _input(event):
	if event.is_action_pressed("num4"):
		var cellIdx = tilemap.world_to_map(get_global_mouse_position())
		createEntity('drill', cellIdx)
		tilemap.get_node("FogOfWar").revealTerrain(cellIdx, true)

func createEntity(entityId : String, cellIdx : Vector2):
	if ENTITIES.has(entityId):
		var entity = ENTITIES[entityId].instance()
		entity.global_position = tilemap.map_to_world(cellIdx)
		entities.add_child(entity)
