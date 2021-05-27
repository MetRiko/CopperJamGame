extends Node2D

onready var level = get_parent().get_parent()
onready var pic = level.getPlayerInputController()

const ALL_SHOP_CONTENT = preload("res://Gui/AllShopContent.gd").ALL_SHOP_CONTENT

onready var gizmo = $Gizmo
onready var floorGizmo = $FloorGizmo

var moduleIdToAttach = null
var rotModuleToAttach = null

func _ready():	
	pic.connect("module_to_attach_changed", self, "onModuleToAttachChanged")
	pic.connect("hovered_object_changed", self, "onHoveredObjectChanged")
	pic.connect("module_selected", self, "onModuleSelected")

func onModuleSelected(module):
	_updateGizmoColor()

func onModuleToAttachChanged(moduleId, rot):
	moduleIdToAttach = moduleId
	rotModuleToAttach = rot
	for content in ALL_SHOP_CONTENT:
		if content.moduleId == moduleId:
			gizmo.frame = content.frameId
			break
	_updateGizmoColor()

func onHoveredObjectChanged(newHoveredObject):	
	var pos = level.getPosFromCellIdx(pic.getMouseIdx())
	gizmo.global_position = pos + level.getHalfCellSize()	
	floorGizmo.global_position = pos + level.getHalfCellSize()

	_updateGizmoColor()

func _updateGizmoColor():
	if moduleIdToAttach != null:
		gizmo.visible = true
		gizmo.rotation_degrees = rotModuleToAttach * 90.0
		var selectedMachine = pic.getSelectedMachine()
		if selectedMachine != null and is_instance_valid(selectedMachine):
			var localIdx = selectedMachine.convertToLocalIdx(pic.getMouseIdx())
			var isAttachable = selectedMachine.canAttachModule(moduleIdToAttach, localIdx, rotModuleToAttach)
			if isAttachable:
				gizmo.modulate = Color(0.0, 1.0, 0.0, 1.0)
			else:
				gizmo.modulate = Color(1.0, 0.0, 0.0, 1.0)
		else:
			gizmo.modulate = Color(1.0, 1.0, 0.0, 1.0)
	else:
		gizmo.visible = false