extends Node2D

onready var level = Game.level
onready var pic = level.getPlayerInputController()
onready var hoverCtrl = level.getHoverObjectController()

var latestHoveredMachine = null
var latestSelectedMachine = null

var possibleConnectionsOffsetsForHoveredMachine = []
var possibleConnectionsOffsetsForSelectedMachine = []

func _ready():
	hoverCtrl.connect("hovered_object_changed", self, "onHoveredObjectChanged")
	pic.connect("module_selected", self, "onModuleSelected")


func onSelectedMachineChanged():
	if latestSelectedMachine != null and is_instance_valid(latestSelectedMachine):
		possibleConnectionsOffsetsForSelectedMachine = latestSelectedMachine.getAllGlobalNeighboursWithOffsets()
	else:
		possibleConnectionsOffsetsForSelectedMachine = []

	update()

func onHoveredMachineChanged():
	if latestHoveredMachine != null and is_instance_valid(latestHoveredMachine):
		possibleConnectionsOffsetsForSelectedMachine = latestHoveredMachine.getAllGlobalNeighboursWithOffsets()
	else:
		possibleConnectionsOffsetsForHoveredMachine = []

	update()

func onModuleSelected(module):
	if module != null:		
		var machine = module.getMachine()

		if latestSelectedMachine != null and is_instance_valid(latestSelectedMachine):
			latestSelectedMachine.disconnect("machine_state_changed", self, "onSelectedMachineChanged")

		latestSelectedMachine = machine
		possibleConnectionsOffsetsForSelectedMachine = machine.getAllGlobalNeighboursWithOffsets()
		machine.connect("machine_state_changed", self, "onSelectedMachineChanged")
	else:
		if latestSelectedMachine != null and is_instance_valid(latestSelectedMachine):
			latestSelectedMachine.disconnect("machine_state_changed", self, "onSelectedMachineChanged")
		latestSelectedMachine = null
		possibleConnectionsOffsetsForSelectedMachine = []
	
	update()

func onHoveredObjectChanged(newHoveredObject):
	
	if newHoveredObject == hoverCtrl.HOVERED_MODULE:
		var machine = hoverCtrl.getHoveredMachine()

		if latestHoveredMachine != null and is_instance_valid(latestHoveredMachine):
			latestHoveredMachine.disconnect("machine_state_changed", self, "onHoveredMachineChanged")

		latestHoveredMachine = machine
		possibleConnectionsOffsetsForHoveredMachine = latestHoveredMachine.getAllGlobalNeighboursWithOffsets()
		latestHoveredMachine.connect("machine_state_changed", self, "onHoveredMachineChanged")
	else:
		if latestHoveredMachine != null and is_instance_valid(latestHoveredMachine):
			latestHoveredMachine.disconnect("machine_state_changed", self, "onHoveredMachineChanged")

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
			var module = idxWithOffset[3].module
			
#			var modulePos = level.getPosFromCellIdx(moduleIdx) + level.getHalfCellSize()
			if module == null or not is_instance_valid(module):
				continue 
			var modulePos = module.global_position + level.getHalfCellSize()
#			
#			var module = machine.getModuleFromLocalIdx(moduleIdx)
#			if module == null or not is_instance_valid(module):
#				continue
#			var modulePos = module.global_position + level.getHalfCellSize()
#			var modulePos = level.getHalfCellSize() + machine.global_position + (machine.getGlobalIdx() - moduleIdx) * level.getCellSize()
			
			var rectCenterPos = modulePos + offset * 16.0 + OFFSETS[(offsetId + 1)%4] * halfWidth
#			var rectCenterPos = level.getPosFromCellIdx(machine.getGlobalIdx() - moduleIdx) + offset * 16.0 + OFFSETS[(offsetId + 1)%4] * halfWidth

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
			
			var globalOffset = Vector2(
				fmod(machine.global_position.x, level.getCellSize().x),
				fmod(machine.global_position.y, level.getCellSize().y)
			)
			
#			var offset2 = modulePos - machine.global_position
			
			var rectPos = Vector2(left, top) + rectCenterPos # - globalOffset
#			var rectPos = Vector2(left, top) + rectCenterPos
			var rectSize = Vector2(right - left, bottom - top)
			
			draw_rect(Rect2(rectPos, rectSize), color, true, 1.0, false)

func _process(delta):
	update()

func _draw():
	_drawOutlineForMachine(latestHoveredMachine, possibleConnectionsOffsetsForHoveredMachine, Color.white, 0.6)
	_drawOutlineForMachine(latestSelectedMachine, possibleConnectionsOffsetsForSelectedMachine, Color.green, 1.3)
