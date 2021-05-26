extends Node2D

onready var level = Game.level
onready var playerInputController = level.getPlayerInputController()

var latestHoveredMachine = null

var possibleConnectionsOffsetsForHoveredMachine = []

func _ready():
	playerInputController.connect("hovered_object_changed", self, "onHoveredObjectChanged")

func onHoveredObjectChanged(newHoveredObject):
	
	if newHoveredObject == playerInputController.HOVERED_MODULE:
		var module = playerInputController.getHoveredModule()
		latestHoveredMachine = module.getMachine()
		possibleConnectionsOffsetsForHoveredMachine = latestHoveredMachine.getAllGlobalNeighboursWithOffsets()
	else:
		latestHoveredMachine = null
		possibleConnectionsOffsetsForHoveredMachine = []
		
	update()

func _draw():

	# hovered machine
	
	if latestHoveredMachine != null and is_instance_valid(latestHoveredMachine):
		
		var halfWidth = 1.0
		var halfLength = level.getHalfCellSize().x + halfWidth
		var size = Vector2(halfWidth * 2.0, halfLength * 2.0)
		
		for idxWithOffset in possibleConnectionsOffsetsForHoveredMachine:
			var moduleIdx = idxWithOffset[0]
			var offset = idxWithOffset[1]
			
			var modulePos = level.getPosFromCellIdx(moduleIdx) + level.getHalfCellSize()
			
			var rectCenterPos = modulePos + offset * 16.0

			var pointsOffsets = [
				Vector2(offset.x, offset.y) * halfWidth,
				-Vector2(offset.x, offset.y) * halfWidth,
				Vector2(offset.y, offset.x) * halfLength,
				-Vector2(offset.y, offset.x) * halfLength
			]
			
			var left = 1000000
			var top = 1000000
			var right = -1000000
			var bottom = -1000000
			for pointOffset in pointsOffsets:
				if left > pointOffset.x:
					left = pointOffset.x
				if top > pointOffset.y:
					top = pointOffset.y
				if right < pointOffset.x:
					right = pointOffset.x
				if bottom < pointOffset.y:
					bottom = pointOffset.y
			
			var rectPos = Vector2(left, top) + rectCenterPos
			var rectSize = Vector2(right - left, bottom - top)
			
			draw_rect(Rect2(rectPos, rectSize), Color.white, true, 1.0, false)
