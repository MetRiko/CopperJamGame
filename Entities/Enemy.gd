extends EntityBase


func _input(event):
	if event.is_action_pressed('i'):
		var pointPath = tilemap.get_node('Pathfinding').pathfind(currentCellIdx, tilemap.world_to_map(get_global_mouse_position()))
		if pointPath.size() >= 2:
			var point =  pointPath[1] - pointPath[0]
			move(Vector2(point.x, point.y))


#func _ready():
#	Game.tilemap.get_node("FogOfWar").revealTerrain(currentCellIdx, true)

func moveForward():
	var result = .moveForward()
	
	if result.success == false:
#		Game.tilemap.set_cell(result.targetCellIdx.x, result.targetCellIdx.y, 1)
#		Game.tilemap.get_node("FogOfWar").revealTerrain(result.targetCellIdx)
		playAnimation()
