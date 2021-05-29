extends Node2D

onready var level = get_parent().get_parent()
onready var pic = level.getPlayerInputController()
onready var hoverCtrl = level.getHoverObjectController()

const ALL_SHOP_CONTENT = preload("res://Gui/AllShopContent.gd").ALL_SHOP_CONTENT

var machineGd = preload("res://Machine/Machine.gd").new()

var latestSelectedMachine = null
var freeSlotsIdxes = []
var latestHoveredObject = null
var possibleConnectionsOffsets = []

var latestModuleIdToAttach = null
var latestRotModuleToAttach = null

func _ready():
	pic.connect("module_selected", self, "onModuleSelected")
	pic.connect("module_to_attach_changed", self, "onModuleToAttachChanged")
	hoverCtrl.connect("hovered_object_changed", self, "onHoveredObjectChanged")
	pic.connect("new_machine_placed", self, "onNewMachinePlaced")
	pic.connect("state_changed", self, "onStateChanged")
	
	onModuleSelected(null)
	onModuleToAttachChanged(null, 0)
	

func onModuleSelected(module):
	
	var nextMachine = module.getMachine() if module != null else null
	_selectMachine(nextMachine)

func _selectMachine(nextMachine):

	if latestSelectedMachine != null and is_instance_valid(latestSelectedMachine):
		if latestSelectedMachine.is_connected("machine_state_changed", self, "onMachineStateChanged"):
			latestSelectedMachine.disconnect("machine_state_changed", self, "onMachineStateChanged")
			latestSelectedMachine.disconnect("machine_removed", self, "onMachineRemoved")
			
	if nextMachine != null:
		if not nextMachine.is_connected("machine_state_changed", self, "onMachineStateChanged"):
			nextMachine.connect("machine_state_changed", self, "onMachineStateChanged")
			nextMachine.connect("machine_removed", self, "onMachineRemoved")

	latestSelectedMachine = nextMachine
	_calculateFreeSlots(nextMachine)

func onMachineStateChanged():
	_calculateFreeSlots(latestSelectedMachine)
	update()

func onNewMachinePlaced(newMachine):
	if newMachine != null:
		_selectMachine(newMachine)
		_calculateFreeSlots(newMachine)

func onModuleToAttachChanged(moduleId, rot):
	latestModuleIdToAttach = moduleId
	latestRotModuleToAttach = rot
	_calculateConnections(moduleId, rot)
	
	if latestSelectedMachine != null and is_instance_valid(latestSelectedMachine):
		_calculateFreeSlots(latestSelectedMachine)

func onHoveredObjectChanged(newHoveredObject):	
	_calculateConnections(latestModuleIdToAttach, latestRotModuleToAttach)
	update()

func onStateChanged(state):
	if state == pic.BUILDING_STATE:
		var selectedModule = pic.getSelectedModule()
		if selectedModule != null and is_instance_valid(selectedModule):
			_calculateFreeSlots(selectedModule.getMachine())
	elif state == pic.NORMAL_STATE:
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
		possibleConnectionsOffsets = []
	else:
		possibleConnectionsOffsets = machineGd.getOffsetsForAvailableConnections(moduleId, rot)
	update()

func _draw():
	if pic.isBuildingState():
		var radius = 4.0
		for idxWithOffset in freeSlotsIdxes:
			var moduleIdx = idxWithOffset[0]
			var offset = idxWithOffset[1]
			var pos = level.getPosFromCellIdx(moduleIdx) + level.getHalfCellSize()
			pos += offset * level.getHalfCellSize()
			draw_circle(pos, radius, Color(1.0, 0.0, 0.0, 0.4))
			draw_circle(pos, radius * 0.85, Color(1.0, 0.0, 0.0, 0.4))
			draw_circle(pos, radius * 0.65, Color(1.0, 0.0, 0.0, 0.4))
			
		for offset in possibleConnectionsOffsets:
			var idx = hoverCtrl.getMouseIdx() 
			var pos = level.getPosFromCellIdx(idx) + level.getHalfCellSize() + offset * level.getHalfCellSize()
			draw_circle(pos, radius, Color(1.0, 0.0, 0.0, 0.4))
			draw_circle(pos, radius * 0.85, Color(1.0, 0.0, 0.0, 0.4))
			draw_circle(pos, radius * 0.65, Color(1.0, 0.0, 0.0, 0.4))
