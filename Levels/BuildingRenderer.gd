extends Node2D

onready var level = get_parent().get_parent()
onready var gizmo = $Gizmo
onready var floorGizmo = $FloorGizmo
onready var playerInputController = level.getPlayerInputController()

var latestSelectedMachine = null
var freeSlotsIdxes = []
var latestHoveredObject = null
var possibleConnectionsOffsets = []

func _ready():
	playerInputController.connect("module_selected", self, "onModuleSelected")
	playerInputController.connect("module_to_attach_changed", self, "onModuleToAttachChanged")
	playerInputController.connect("hovered_object_changed", self, "onHoveredObjectChanged")
	playerInputController.connect("new_machine_placed", self, "onNewMachinePlaced")
	
	onModuleSelected(null)
	onModuleToAttachChanged(null, 0)
	

func onModuleSelected(module):
	if latestSelectedMachine != null and is_instance_valid(latestSelectedMachine) and latestSelectedMachine != module:

		latestSelectedMachine.disconnect("machine_state_changed", self, "onMachineStateChanged")

	if module != null:
		latestSelectedMachine = module.getMachine()
		latestSelectedMachine.connect("machine_state_changed", self, "onMachineStateChanged")

func onMachineStateChanged():
	if latestSelectedMachine != null and is_instance_valid(latestSelectedMachine):
		freeSlotsIdxes = latestSelectedMachine.getAvailableGlobalFreeSlots()
	else:
		freeSlotsIdxes = []
	
	update()

func onNewMachinePlaced(newMachine):
	freeSlotsIdxes = newMachine.getAvailableGlobalFreeSlots()
	if latestSelectedMachine != newMachine:
		newMachine.getMachine().connect("machine_state_changed", self, "onMachineStateChanged")
	latestSelectedMachine = newMachine
	update()

func onModuleToAttachChanged(moduleId, rot):
	if moduleId == null:
		gizmo.visible = false
		possibleConnectionsOffsets = []
	else:
		gizmo.visible = true
		gizmo.rotation = rot * 90.0
		if latestSelectedMachine != null and is_instance_valid(latestSelectedMachine):
			possibleConnectionsOffsets = latestSelectedMachine.getOffsetsForAvailableConnections(moduleId, rot)
		else:
			possibleConnectionsOffsets = []
	update()

func onHoveredObjectChanged(newHoveredObject):
	var floorGizmoSize = floorGizmo.get_rect().size * floorGizmo.global_scale

	var pos = level.getPosFromCellIdx(playerInputController.getMouseIdx())
	gizmo.global_position = pos
	floorGizmo.global_position = pos + level.getHalfCellSize() #level.getCellSize() - floorGizmoSize)
	print(level.getCellSize() - floorGizmoSize)

func _draw():
	var radius = 4.0
	for idx in freeSlotsIdxes:
		var pos = level.getPosFromCellIdx(idx) + level.getHalfCellSize()
		draw_circle(pos, radius, Color(1.0, 0.0, 0.0, 0.4))
		
	for offset in possibleConnectionsOffsets:
		var idx = playerInputController.getMouseIdx() 
		var pos = level.getPosFromCellIdx(idx) + level.getHalfCellSize() + offset * level.getHalfCellSize()
		draw_circle(pos, radius, Color(0.0, 0.0, 1.0, 0.4))
