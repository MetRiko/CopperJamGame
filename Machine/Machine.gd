extends Node2D

signal module_removed

onready var level = Game.level

onready var modules = $VC/Viewport/Modules
onready var processor = $Processor

const MODULES = {
	'dpad_module': {
		'tscn': preload("res://Machine/Modules/DPadModule.tscn"),
		'connections': ['left', 'right', 'up', 'down']
	},
	'empty_module': {
		'tscn': preload("res://Machine/Modules/EmptyModule.tscn"),
		'connections': ['left', 'right', 'up', 'down']
	},
	'diode_module': {
		'tscn': preload("res://Machine/Modules/DiodeModule.tscn"),
		'connections': ['left', 'right', 'up', 'down']
	}
}

const CONNECTIONS_TRANSLATION = {
	'up': 0,
	'right': 1,
	'down': 2,
	'left': 3
}

const OFFSETS = [
	Vector2(0, -1),
	Vector2(1, 0),
	Vector2(0, 1),
	Vector2(-1, 0)
]

var installedModules := {} # hashedLocalIdx: {module, localIdx} per module
var availableIdxes := {} #local

var baseModule = null
var baseGlobalIdx := Vector2()

func _input(event):
	if event.is_action_pressed("ui_up"):
		justCallInstruction(Vector2(0, 0), 'move_up')
	if event.is_action_pressed("ui_down"):
		justCallInstruction(Vector2(0, 0), 'move_down')
	if event.is_action_pressed("ui_left"):
		justCallInstruction(Vector2(0, 0), 'move_left')
	if event.is_action_pressed("ui_right"):
		justCallInstruction(Vector2(0, 0), 'move_right')

############### Positions and idxes
	
func getGlobalIdx():
	return baseGlobalIdx

func convertToLocalIdx(globalIdx : Vector2):
	return globalIdx - baseGlobalIdx
	
func convertToGlobalIdx(localIdx : Vector2):
	return localIdx + baseGlobalIdx

############### Available slots

func getAvailableGlobalFreeSlots():
	var ret = []
	for localIdx in availableIdxes.values():
		if not level.isObstacle(convertToGlobalIdx(localIdx)):
			ret.append(convertToGlobalIdx(localIdx))
	return ret
	
func getAvailableLocalFreeSlots():
	return availableIdxes.values()
	
func addAvailableIdx(idx : Vector2):
	var hashedIdx = hashIdx(idx)
	if not installedModules.has(hashedIdx):
		availableIdxes[hashedIdx] = idx
		update()
	
func removeAvailableIdx(idx : Vector2):
	var hashedIdx = hashIdx(idx)
	if  availableIdxes.has(hashedIdx):
		availableIdxes.erase(hashedIdx)
		update()
		
############### Processor

func justCallInstruction(localModuleIdx : Vector2, instructionId : String):
	$Processor.justCallInstruction(localModuleIdx, instructionId)

############### Movement

func canMove(offset : Vector2):
	return $Movement.canMove(offset)

func move(offset : Vector2):
	$Movement.move(offset)

############### Getters

func getProcessor():
	return processor

func hasModules():
	return not installedModules.empty()

func getModulesCount():
	return installedModules.size()

func getModuleFromLocalIdx(localIdx):
	var hashedLocalIdx = hashIdx(localIdx)
	var module = installedModules.get(hashedLocalIdx)
	if module != null:
		return module.module
	return null
	
############### Core
	
func _ready():
	$VC.material = $VC.material.duplicate()
	for module in modules.get_children():
		module.queue_free()

func setupPos(globalIdx : Vector2):
	baseGlobalIdx = globalIdx
	var pos = level.getPosFromCellIdx(globalIdx)
	global_position = pos
#	print(pos)
	addAvailableIdx(Vector2(0, 0))

func _recalculateViewportSize():
	
	if installedModules.empty():
		$VC/Viewport.size = level.tilemap.cell_size + Vector2(20, 20)
	
	var minPoint = Vector2(10000000, 10000000)
	var maxPoint = Vector2(-10000000, -10000000)
	
	for moduleData in installedModules.values():
		var localIdx = moduleData.localIdx
		if localIdx.x < minPoint.x:
			minPoint.x = localIdx.x
		if localIdx.y < minPoint.y:
			minPoint.y = localIdx.y
		if localIdx.x > maxPoint.x:
			maxPoint.x = localIdx.x
		if localIdx.y > maxPoint.y:
			maxPoint.y = localIdx.y
		
	var margin = Vector2(20.0, 20.0)
		
	var viewPosition = minPoint * level.tilemap.cell_size
	$VC.rect_position = viewPosition - margin
	
	var viewSize = (maxPoint - minPoint + Vector2(1, 1)) * level.tilemap.cell_size
	$VC.rect_size = viewSize + margin * 2
	
	var dif = baseGlobalIdx - convertToGlobalIdx(minPoint)
	modules.position = dif * level.tilemap.cell_size + margin


############### Building

func isIdxInMachine(globalIdx : Vector2):
	var hashedLocalIdx = hashIdx(convertToLocalIdx(globalIdx))
	return installedModules.has(hashedLocalIdx)

func checkIfIdxAvailable(idx : Vector2):
	var hashedIdx = hashIdx(idx)
	return availableIdxes.has(hashedIdx)
	
func getOffsetsIdForAvailableConnections(moduleId : String, moduleLocalIdx : Vector2, rot := 0):
	var moduleConnections = MODULES[moduleId].connections
	var offsetsId = []
	for connection in moduleConnections:
		var offsetIdWithoutRotation = CONNECTIONS_TRANSLATION[connection]
		var offsetIdAfterRotation = (offsetIdWithoutRotation + rot) % 4
		offsetsId.append(offsetIdAfterRotation)
	return offsetsId
	
func getAvailableConnections(moduleId : String, moduleLocalIdx : Vector2, rot := 0):
	var offsetsIdAfterRotation = getOffsetsIdForAvailableConnections(moduleId, moduleLocalIdx, rot)
	var availableConnections = []
	for offsetId in offsetsIdAfterRotation:
		availableConnections.append(OFFSETS[offsetId] + moduleLocalIdx)
	return availableConnections
	
func getAvailableIdxes(moduleId : String, moduleLocalIdx : Vector2, rot := 0):
	var offsetsIdAfterRotation = getOffsetsIdForAvailableConnections(moduleId, moduleLocalIdx, rot)
	var availableIdxes = []
	for offsetId in offsetsIdAfterRotation:
		availableIdxes.append(OFFSETS[(offsetId + 2) % 4] + moduleLocalIdx)
	return availableIdxes

func isAnyConnectionAvailable(moduleId : String, moduleLocalIdx : Vector2, rot := 0):
	if installedModules.empty():
		return true
	var availableConnections = getAvailableConnections(moduleId, moduleLocalIdx, rot)
	for localIdx in availableConnections:
		var hashedLocalIdx = hashIdx(localIdx)
		if installedModules.get(hashedLocalIdx) != null:
			return true
	return false

func canDetachModule(localIdx : Vector2):
	if installedModules.size() == 0:
		return false
	if installedModules.size() == 1 and installedModules.values()[0].localIdx == localIdx:
		return true
		
	var modulesChecked = {}
	var firstModuleIdx = installedModules.values()[0].localIdx
	if firstModuleIdx == localIdx:
		firstModuleIdx = installedModules.values()[1].localIdx
	var hashedFirstModuleIdx = hashIdx(firstModuleIdx)
	modulesChecked[hashedFirstModuleIdx] = firstModuleIdx
	_canDetachModule(localIdx, firstModuleIdx, modulesChecked)
	return modulesChecked.size() == installedModules.size() - 1
	
func _canDetachModule(ignoredIdx : Vector2, localIdx : Vector2, modulesChecked : Dictionary):
	var modulesToCheck = [
		localIdx + OFFSETS[0],
		localIdx + OFFSETS[1],
		localIdx + OFFSETS[2],
		localIdx + OFFSETS[3]
	]
	
	for moduleIdx in modulesToCheck:
		if moduleIdx != ignoredIdx and not modulesChecked.has(hashIdx(moduleIdx)):
			var hashedModuleIdx := hashIdx(moduleIdx)
			if installedModules.has(hashedModuleIdx):
				modulesChecked[hashedModuleIdx] = moduleIdx
				_canDetachModule(ignoredIdx, moduleIdx, modulesChecked)

func recalculateAvailableIdxes():
	if installedModules.empty():
		var hashedIdx = hashIdx(Vector2(0, 0))
		self.availableIdxes = {}
		self.availableIdxes[hashedIdx] = Vector2(0, 0)
		return
		
	var newAvailableIdxes = {}
	for moduleData in installedModules.values():
		var availableIdxes = moduleData.availableIdxes
		for idx in availableIdxes:
			var hashedIdx = hashIdx(idx)
			if not hashedIdx in installedModules:
				newAvailableIdxes[hashedIdx] = idx
	self.availableIdxes = newAvailableIdxes

func detachModule(localIdx : Vector2):
	if not canDetachModule(localIdx):
		printerr("Cannot detach this module!")
		push_error("Cannot detach this module!")
		return 
	
	
	var hashedLocalIdx = hashIdx(localIdx)
	var moduleData = installedModules[hashedLocalIdx]
	if installedModules.size() == 1:
		baseGlobalIdx = convertToGlobalIdx(moduleData.localIdx)
		global_position = level.getPosFromCellIdx(baseGlobalIdx)
	
	processor.removeNodesRelatedToModule(localIdx)
	emit_signal("module_removed", self, localIdx, moduleData.module)
	moduleData.module.queue_free()
	installedModules.erase(hashedLocalIdx)
	recalculateAvailableIdxes()
	
	_recalculateViewportSize()
	
	
	

func attachModule(moduleId : String, localIdx : Vector2, rot := 0): #local idx
	
	if not checkIfIdxAvailable(localIdx):
		printerr("Unavailable module idx!")
		push_error("Unavailable module idx!")
		return

	if not isAnyConnectionAvailable(moduleId, localIdx, rot):
		push_error("No available connection for this module!")
		printerr("No available connection for this module!")
		return
		
	var offsetsIdForConnections = getOffsetsIdForAvailableConnections(moduleId, localIdx, rot)
	var availableConnections = getAvailableConnections(moduleId, localIdx, rot)
	var availableIdxes = getAvailableIdxes(moduleId, localIdx, rot)

	var newModule = MODULES[moduleId].tscn.instance()
	var hashedIdx = hashIdx(localIdx)
	installedModules[hashedIdx] = {
		'module': newModule,
		'localIdx': localIdx,
		'rot': rot,
		'availableConnections': availableConnections,
		'availableIdxes': availableIdxes
	}

	modules.add_child(newModule)
	newModule.setupModule(self, localIdx)
	newModule.position = level.getPosFromCellIdx(localIdx)
	removeAvailableIdx(localIdx)
	for offsetId in offsetsIdForConnections: 
		addAvailableIdx(OFFSETS[(offsetId)%4] + localIdx)
	
	_recalculateViewportSize()
		
func getLocalMouseIdx():
	return level.getCellIdxFromPos(get_global_mouse_position()) - baseGlobalIdx

#func _unhandled_input(event):
#	if event.is_action_pressed("LMB"):
#		var mouseIdx = getLocalMouseIdx()
#		var hashedMouseIdx = hashIdx(mouseIdx)
#		if hashedMouseIdx in availableIdxes:
#			if not level.isObstacle(mouseIdx + baseGlobalIdx):
#				attachModule('empty_module', mouseIdx)
#	if event.is_action_pressed("RMB"):
#		var mouseIdx = getLocalMouseIdx()
#		var hashedMouseIdx = hashIdx(mouseIdx)
#		if hashedMouseIdx in installedModules:
#			detachModule(mouseIdx)

#func _process(delta):
#	update()
#
#func _draw():
#	var mouseIdx = getLocalMouseIdx()
#	var hashedMouseIdx = hashIdx(mouseIdx)
#	if hashedMouseIdx in availableIdxes:
#		var rectPos = level.getPosFromCellIdx(mouseIdx)
#		draw_rect(Rect2(rectPos, level.tilemap.cell_size), Color.wheat, false, 1.0)
#		print(rectPos)
#
#	for idx in getAvailableGlobalFreeSlots():
#		var pos = level.getPosFromCellIdx(convertToLocalIdx(idx)) + level.tilemap.cell_size * 0.5
#		draw_circle(pos, 6.0, Color.wheat)

func hashIdx(idx : Vector2) -> int:
	var x = idx.x
	var y = idx.y
	var a = -2*x-1 if x < 0 else 2 * x
	var b = -2*y-1 if y < 0 else 2 * y
	return (a + b) * (a + b + 1) * 0.5 + b

############### Outline

func setOutline(width : float, color := Color.white):
	$VC.material.set_shader_param('width', width)
	$VC.material.set_shader_param('outline_color', color)
