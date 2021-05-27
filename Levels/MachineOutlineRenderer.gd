extends Node2D

onready var level = Game.level
onready var playerInputController = level.getPlayerInputController()

var latestHoveredMachine = null
var latestSelectedMachine = null

var possibleConnectionsOffsetsForHoveredMachine = []
var possibleConnectionsOffsetsForSelectedMachine = []

func _ready():
	playerInputController.connect("hovered_object_changed", self, "onHoveredObjectChanged")
	playerInputController.connect("module_selected", self, "onModuleSelected")

func onModuleSelected(module):
	if module != null:
		var machine = module.getMachine()
		latestSelectedMachine = machine
		possibleConnectionsOffsetsForSelectedMachine = machine.getAllGlobalNeighboursWithOffsets()
	else:
		latestSelectedMachine = null
		possibleConnectionsOffsetsForSelectedMachine = []
	
	update()

func onHoveredObjectChanged(newHoveredObject):
	
	if newHoveredObject == playerInputController.HOVERED_MODULE:
		var module = playerInputController.getHoveredModule()
		latestHoveredMachine = module.getMachine()
		possibleConnectionsOffsetsForHoveredMachine = latestHoveredMachine.getAllGlobalNeighboursWithOffsets()
	else:
		latestHoveredMachine = null
		possibleConnectionsOffsetsForHoveredMachine = []
		
	update()


func _drawOutlineForMachine(machine, connectionsOffsets, color, thickness):
		# hovered machine
	
	if machine != null and is_instance_valid(machine):
		
		var OFFSETS = [
			Vector2(0, -1),
			Vector2(1, 0),
			Vector2(0, 1),
			Vector2(-1, 0)
		]
		
		var halfWidth = thickness
		var halfLength = level.getHalfCellSize().x
		var size = Vector2(halfWidth * 2.0, halfLength * 2.0)
		
		for idxWithOffset in connectionsOffsets:
			var moduleIdx = idxWithOffset[0]
			var offset = idxWithOffset[1]
			var offsetId = idxWithOffset[2]
			
			var modulePos = level.getPosFromCellIdx(moduleIdx) + level.getHalfCellSize()
			
			var rectCenterPos = modulePos + offset * 16.0 + OFFSETS[(offsetId + 1)%4] * halfWidth

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
			
			draw_rect(Rect2(rectPos, rectSize), color, true, 1.0, false)


func _draw():
	_drawOutlineForMachine(latestHoveredMachine, possibleConnectionsOffsetsForHoveredMachine, Color.white, 0.6)
	_drawOutlineForMachine(latestSelectedMachine, possibleConnectionsOffsetsForSelectedMachine, Color.green, 1.3)
