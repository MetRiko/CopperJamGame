extends Node2D

onready var level = get_parent().get_parent()
onready var gizmo = $Gizmo
onready var floorGizmo = $FloorGizmo
onready var playerInputController = level.getPlayerInputController()

const ALL_SHOP_CONTENT = preload("res://Gui/AllShopContent.gd").ALL_SHOP_CONTENT

var latestSelectedMachine = null
var freeSlotsIdxes = []
var latestHoveredObject = null
var possibleConnectionsOffsets = []

var latestModuleIdToAttach = null
var latestRotModuleToAttach = null

func _ready():
	playerInputController.connect("module_selected", self, "onModuleSelected")
	playerInputController.connect("module_to_attach_changed", self, "onModuleToAttachChanged")
	playerInputController.connect("hovered_object_changed", self, "onHoveredObjectChanged")
	playerInputController.connect("new_machine_placed", self, "onNewMachinePlaced")
	playerInputController.connect("state_changed", self, "onStateChanged")
	
	onModuleSelected(null)
	onModuleToAttachChanged(null, 0)
	

func onModuleSelected(module):
	
	var nextMachine = module.getMachine() if module != null else null
	
	if latestSelectedMachine != nextMachine and nextMachine != null:
		nextMachine.connect("machine_state_changed", self, "onMachineStateChanged")
		nextMachine.connect("machine_removed", self, "onMachineRemoved")
		if latestSelectedMachine != null and is_instance_valid(latestSelectedMachine):
			if latestSelectedMachine.is_connected("machine_state_changed", self, "onMachineStateChanged"):
				latestSelectedMachine.disconnect("machine_state_changed", self, "onMachineStateChanged")
				latestSelectedMachine.disconnect("machine_removed", self, "onMachineRemoved")
		
	latestSelectedMachine = nextMachine
	_calculateFreeSlots(nextMachine)

#	if latestSelectedMachine != null and is_instance_valid(latestSelectedMachine):
#		if (module != null and latestSelectedMachine != module.getMachine()) or module == null:
#			latestSelectedMachine.disconnect("machine_state_changed", self, "onMachineStateChanged")
#			latestSelectedMachine.disconnect("machine_removed", self, "onMachineRemoved")
#
#	if module != null:
#		var nextMachine = module.getMachine()
#		if latestSelectedMachine != nextMachine:
#			nextMachine.connect("machine_state_changed", self, "onMachineStateChanged")
#			nextMachine.connect("machine_removed", self, "onMachineRemoved")
#		latestSelectedMachine = nextMachine
#		_calculateFreeSlots(latestSelectedMachine)
#	else:
#		latestSelectedMachine = null

func onMachineStateChanged():
	if latestSelectedMachine != null and is_instance_valid(latestSelectedMachine):
		if latestSelectedMachine.getModulesCount() == 0:
			freeSlotsIdxes = []
		else:
			freeSlotsIdxes = latestSelectedMachine.getAllAvailableGlobalFreeSlotsWithOffsets()
	else:
		freeSlotsIdxes = []
	update()

func onNewMachinePlaced(newMachine):
	_calculateFreeSlots(newMachine)

func onModuleToAttachChanged(moduleId, rot):
	latestModuleIdToAttach = moduleId
	latestRotModuleToAttach = rot
	_calculateConnections(moduleId, rot)
	for content in ALL_SHOP_CONTENT:
		if content.moduleId == moduleId:
			gizmo.frame = content.frameId
			break
	
	if latestSelectedMachine != null and is_instance_valid(latestSelectedMachine):
		_calculateFreeSlots(latestSelectedMachine)

	_updateGizmoColor()

func onHoveredObjectChanged(newHoveredObject):
	var floorGizmoSize = floorGizmo.get_rect().size * floorGizmo.global_scale

	var pos = level.getPosFromCellIdx(playerInputController.getMouseIdx())
	gizmo.global_position = pos + level.getHalfCellSize() + Vector2(-1, 0)
	floorGizmo.global_position = pos + level.getHalfCellSize() + Vector2(-1, 0)
	
	_calculateConnections(latestModuleIdToAttach, latestRotModuleToAttach)
	_updateGizmoColor()

func _updateGizmoColor():
	if latestModuleIdToAttach != null:
		if latestSelectedMachine != null and is_instance_valid(latestSelectedMachine):
			var localIdx = latestSelectedMachine.convertToLocalIdx(playerInputController.getMouseIdx())
			var isAttachable = latestSelectedMachine.canAttachModule(latestModuleIdToAttach, localIdx, latestRotModuleToAttach)
			if isAttachable:
				gizmo.modulate = Color(0.0, 1.0, 0.0, 1.0)
			else:
				gizmo.modulate = Color(1.0, 0.0, 0.0, 1.0)
		else:
			gizmo.modulate = Color(1.0, 1.0, 0.0, 1.0)

func onStateChanged(state):
	if state == playerInputController.BUILDING_STATE:
		var selectedModule = playerInputController.getSelectedModule()
		if selectedModule != null and is_instance_valid(selectedModule):
			_calculateFreeSlots(selectedModule.getMachine())
	elif state == playerInputController.NORMAL_STATE:
		_calculateFreeSlots(null)

func onMachineRemoved():
	_calculateFreeSlots(null)

func _calculateFreeSlots(machine):
	if machine != null and is_instance_valid(machine):
		freeSlotsIdxes = machine.getAllAvailableGlobalFreeSlotsWithOffsets()
		latestSelectedMachine = machine
	else:
		freeSlotsIdxes = []
	update()

func _calculateConnections(moduleId, rot):
	if moduleId == null:
		gizmo.visible = false
		possibleConnectionsOffsets = []
	else:
		gizmo.visible = true
		gizmo.rotation_degrees = rot * 90.0
		if latestSelectedMachine != null and is_instance_valid(latestSelectedMachine):
			possibleConnectionsOffsets = latestSelectedMachine.getOffsetsForAvailableConnections(moduleId, rot)
		else:
			possibleConnectionsOffsets = []
	update()

func _draw():
	var radius = 4.0
	for idxWithOffset in freeSlotsIdxes:
		var moduleIdx = idxWithOffset[0]
		var offset = idxWithOffset[1]
		print(offset)
		var pos = level.getPosFromCellIdx(moduleIdx) + level.getHalfCellSize()
		pos += offset * level.getHalfCellSize()
		draw_circle(pos, radius, Color(1.0, 0.0, 0.0, 0.4))
		
	for offset in possibleConnectionsOffsets:
		var idx = playerInputController.getMouseIdx() 
		var pos = level.getPosFromCellIdx(idx) + level.getHalfCellSize() + offset * level.getHalfCellSize()
		draw_circle(pos, radius, Color(0.0, 0.0, 1.0, 0.4))
