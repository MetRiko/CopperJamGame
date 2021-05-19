extends Node

signal cells_revealed

onready var tilemap = get_parent()
onready var mapGenerator = tilemap.get_node("MapGenerator")

func getCellIdx(pos : Vector2) -> Vector2:
	return tilemap.world_to_map(pos)

func getCell(cellIdx : Vector2) -> int:
	return tilemap.get_cell(cellIdx.x, cellIdx.y) 

func hashCellIdx(cellIdx):
	return cellIdx.x * 10000000 + cellIdx.y

func revealTerrain(cellIdx, forceLight := false):
	var cell = getCell(cellIdx)
	if cell != 1:
		return
	
	var spreadedCells := {shouldSpread = forceLight}
	var spreadedCellsArr := []
	_revealTerrain(cellIdx, spreadedCells, spreadedCellsArr)
	
	if spreadedCells.shouldSpread == true:
		spreadedCells.erase('shouldSpread')
		for cellIdx in spreadedCells.values():
			tilemap.set_cell(cellIdx.x, cellIdx.y, 2)
		
		emit_signal("cells_revealed", spreadedCells.values())

const CELLS_OFFSETS = [
	Vector2(-1, 0),
	Vector2(1, 0),
	Vector2(0, -1),
	Vector2(0, 1),
]

func _revealTerrain(firstCellIdx : Vector2, spreadedCells : Dictionary, spreadedCellsArr : Array):
	
#	var c := 0
	
	spreadedCellsArr.append(firstCellIdx)
	var hashedFirstCellIdx = hashCellIdx(firstCellIdx)
	spreadedCells[hashedFirstCellIdx] = firstCellIdx
	
	for cellIdx in spreadedCellsArr:
		for offset in CELLS_OFFSETS:
			var offsetedCellIdx = cellIdx + offset
			var cell = getCell(offsetedCellIdx)
			if cell == 1:
				var hashedOffsetedCellIdx = hashCellIdx(offsetedCellIdx)
				if not spreadedCells.has(hashedOffsetedCellIdx):
					spreadedCells[hashedOffsetedCellIdx] = offsetedCellIdx
					spreadedCellsArr.append(offsetedCellIdx)
			elif cell == 2:
				spreadedCells.shouldSpread = true

#func _revealTerrain(cellIdx, spreadedCells, spreadedCellsArr):
#	var hashedCell = hashCellIdx(cellIdx)
#
#	if not spreadedCells.has(hashedCell):
#		spreadedCells[hashedCell] = cellIdx
#
#		for offset in CELLS_OFFSETS:
#			var offsetedCellIdx = cellIdx + offset
#			var cell = getCell(offsetedCellIdx)
#			if cell == 1:
#				_revealTerrain(offsetedCellIdx, spreadedCells, spreadedCellsArr)
#			elif cell == 2:
#				spreadedCells.shouldSpread = true
