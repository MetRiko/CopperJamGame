extends Node


onready var tilemap = get_parent()

func getCellIdx(pos : Vector2) -> Vector2:
	return tilemap.world_to_map(pos)

func getCell(cellIdx : Vector2) -> int:
	return tilemap.get_cell(cellIdx.x, cellIdx.y) 

func _input(event):
	if event.is_action_pressed("LMB"):
		var cellIdx := getCellIdx(tilemap.get_global_mouse_position())
		var cell := getCell(cellIdx)
		if cell != -1:
			reavealTerrain(cellIdx)
		
var spreadedCells := {}

func hashCellIdx(cellIdx):
	return cellIdx.x * 10000000 + cellIdx.y

func reavealTerrain(cellIdx):
	var cell = getCell(cellIdx)
	if cell != 1:
		return
	
	_reavealTerrain(cellIdx)
	
	for cellIdx in spreadedCells.values():
		tilemap.set_cell(cellIdx.x, cellIdx.y, 2)

const CELLS_OFFSETS = [
	Vector2(-1, 0),
	Vector2(1, 0),
	Vector2(0, -1),
	Vector2(0, 1),
]

func _reavealTerrain(cellIdx):
	var hashedCell = hashCellIdx(cellIdx)
	
	if not spreadedCells.has(hashedCell):
		spreadedCells[hashedCell] = cellIdx
		
		for offset in CELLS_OFFSETS:
			var offsetedCellIdx = cellIdx + offset
			var cell = getCell(offsetedCellIdx)
			if cell == 1:
				_reavealTerrain(offsetedCellIdx)
