extends Node2D

signal module_removed
signal machine_removed
signal machine_state_changed

onready var level = Game.level

onready var modules = $Modules
onready var processor = $Processor
onready var healthControllers = $HealthControllers

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
	},
	'turret_module': {
		'tscn': preload("res://Machine/Modules/TurretModule.tscn"),
		'connections': ['down']
	},
	'pylon_module': {
		'tscn': preload("res://Machine/Modules/PylonModule.tscn"),
		'connections': []
	},
	'generator_module': {
		'tscn': preload("res://Machine/Modules/GeneratorModule.tscn"),
		'connections': []
	},
	'drill_module': {
		'tscn': preload("res://Machine/Modules/DrillModule.tscn"),
		'connections': ['down']
	},
	'vertical_module': {
		'tscn': preload("res://Machine/Modules/VerticalModule.tscn"),
		'connections': ['left', 'right', 'up', 'down']
	},
	'horizontal_module': {
		'tscn': preload("res://Machine/Modules/HorizontalModule.tscn"),
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

var removeMachine = false
var modulesQueuedToRemove = []

func _input(event):
	if event.is_action_pressed("ui_up"):
		justCallInstruction(Vector2(0, 0), 'move_up')
	if event.is_action_pressed("ui_down"):
		justCallInstruction(Vector2(0, 0), 'move_down')
	if event.is_action_pressed("ui_left"):
		justCallInstruction(Vector2(0, 0), 'move_left')
	if event.is_action_pressed("ui_right"):
		justCallInstruction(Vector2(0, 0), 'move_right')
		
#	if event.is_action_pressed("num7"):
#		var idx = getLocalMouseIdx()
#		detachModule(idx, true)
		
	if event.is_action_pressed("num8"):
		var idx = getLocalMouseIdx()
		damageModuleOnLocalIdx(idx, 1.0)

############### Positions and idxes
	
func getGlobalIdx():
	return baseGlobalIdx

func convertToLocalIdx(globalIdx : Vector2):
	return globalIdx - baseGlobalIdx
	
func convertToGlobalIdx(localIdx : Vector2):
	return localIdx + baseGlobalIdx

############### Available slots

func getAllGlobalNeighboursWithOffsets():
	var neighbours = []
	for module in installedModules.values():
		var i = -1
		for offset in OFFSETS:
			i += 1
			var idx = module.localIdx + offset
			var hashedIdx = hashIdx(idx)
			if not installedModules.has(hashedIdx):
				neighbours.append([convertToGlobalIdx(module.localIdx), offset, i])
	return neighbours

func getAllAvailableGlobalFreeSlotsWithOffsets():
	var ret = []
	for module in installedModules.values():
		for idx in module.availableIdxes:
			if availableIdxes.values().has(idx):
				var offset = idx - module.localIdx
				var globalIdx = convertToGlobalIdx(module.localIdx)
				ret.append([globalIdx, offset])
	return ret 

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

func getModules():
	return installedModules.values()

func getModulesCount():
	return installedModules.size()

func getModuleFromLocalIdx(localIdx):
	var hashedLocalIdx = hashIdx(localIdx)
	var module = installedModules.get(hashedLocalIdx)
	if module != null:
		return module.module
	return null

func getModuleFromGlobalIdx(globalIdx):
	return getModuleFromLocalIdx(convertToLocalIdx(globalIdx))

############### Health

func damageModuleOnLocalIdx(localIdx, damageValue):
	var hashedLocalIdx = hashIdx(localIdx)
	var module = installedModules.get(hashedLocalIdx)
	if module != null:
		module.module.doDamage(damageValue)
	else:
		push_error("Module doesn't exist") 

############### Core

var clearingState = 0

func _process(delta):
	if not modulesQueuedToRemove.empty():
		for module in modulesQueuedToRemove:
			module.destroy()
			modulesQueuedToRemove.erase(module)
		if installedModules.empty():
			$CoreBorder.visible = false

#func _process(delta):
#	if not modulesQueuedToRemove.empty() and clearingState == 0:
#		if removeMachine == true:
#			$CoreBorder.visible = false
#		clearingState = 1
#		for module in modulesQueuedToRemove:
#			module.destroy()
##		yield(get_tree().create_timer(0.8), "timeout")
##		for module in modulesQueuedToRemove:
##			module.queue_free()
#		modulesQueuedToRemove = []
#		_recalculateViewportSize()
#		clearingState = 0
#		if removeMachine == true:
#			queue_free()

func onModuleDestroyed():
	if modulesQueuedToRemove.empty():
#		_recalculateViewportSize()
		
		if installedModules.empty():
			queue_free()

func _ready():
	for module in modules.get_children():
		module.queue_free()

func setupPos(globalIdx : Vector2):
	baseGlobalIdx = globalIdx
	var pos = level.getPosFromCellIdx(globalIdx)
	global_position = pos
	addAvailableIdx(Vector2(0, 0))

#func _recalculateViewportSize():
#
#	if installedModules.empty():
#		$VC/Viewport.size = level.getCellSize() + Vector2(20, 20)
#
#	var minPoint = Vector2(10000000, 10000000)
#	var maxPoint = Vector2(-10000000, -10000000)
#
#	for moduleData in installedModules.values():
#		var localIdx = moduleData.localIdx
#		if localIdx.x < minPoint.x:
#			minPoint.x = localIdx.x
#		if localIdx.y < minPoint.y:
#			minPoint.y = localIdx.y
#		if localIdx.x > maxPoint.x:
#			maxPoint.x = localIdx.x
#		if localIdx.y > maxPoint.y:
#			maxPoint.y = localIdx.y
#
#	var margin = Vector2(20.0, 20.0)
#
#	var viewPosition = minPoint * level.getCellSize()
#	$VC.rect_position = viewPosition - margin
#
#	var viewSize = (maxPoint - minPoint + Vector2(1, 1)) * level.getCellSize()
#	$VC.rect_size = viewSize + margin * 2
#
#	var dif = baseGlobalIdx - convertToGlobalIdx(minPoint)
#	modules.position = dif * level.getCellSize() + margin


############### Building

func isIdxInMachine(globalIdx : Vector2):
	var hashedLocalIdx = hashIdx(convertToLocalIdx(globalIdx))
	return installedModules.has(hashedLocalIdx)

func checkIfIdxAvailable(localIdx : Vector2):
	var hashedIdx = hashIdx(localIdx)
	return availableIdxes.has(hashedIdx)

func getOffsetsForAvailableConnections(moduleId : String, rot := 0):
	var offsets = []
	var ids = getOffsetsIdForAvailableConnections(moduleId, rot)
	for id in ids:
		offsets.append(OFFSETS[id])
	return offsets

func getOffsetsIdForAvailableConnections(moduleId : String, rot := 0):
	var moduleConnections = MODULES[moduleId].connections
	var offsetsId = []
	for connection in moduleConnections:
		var offsetIdWithoutRotation = CONNECTIONS_TRANSLATION[connection]
		var offsetIdAfterRotation = (offsetIdWithoutRotation + rot + 4) % 4
		offsetsId.append(offsetIdAfterRotation)
	return offsetsId
	
func getAvailableConnections(moduleId : String, moduleLocalIdx : Vector2, rot := 0):
	var offsetsIdAfterRotation = getOffsetsIdForAvailableConnections(moduleId, rot)
	var availableConnections = []
	for offsetId in offsetsIdAfterRotation:
		availableConnections.append(OFFSETS[offsetId] + moduleLocalIdx)
	return availableConnections
	
func getAvailableIdxes(moduleId : String, moduleLocalIdx : Vector2, rot := 0):
	var offsetsIdAfterRotation = getOffsetsIdForAvailableConnections(moduleId, rot)
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
		var module = installedModules.get(hashedLocalIdx)
		if module != null:
			var freeSlotsFromModule = module.availableIdxes
			for freeSlotIdx in freeSlotsFromModule:
				if freeSlotIdx == moduleLocalIdx:
					return true
	return false

func canDetachModule(localIdx : Vector2):
	if installedModules.size() == 0:
		return false
	if localIdx == Vector2(0, 0) and installedModules.size() > 1:
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

func detachModule(localIdx : Vector2, forceDetach = false, emitSignal = true):
	if not canDetachModule(localIdx):
		if forceDetach == true:
			_forceDetach(localIdx, emitSignal)
			return
		else:
			push_error("Cannot detach module!")
			return 
	
	var hashedLocalIdx = hashIdx(localIdx)
	var moduleData = installedModules[hashedLocalIdx]
	if installedModules.size() == 1:
		baseGlobalIdx = convertToGlobalIdx(moduleData.localIdx)
		global_position = level.getPosFromCellIdx(baseGlobalIdx)
	
	processor.removeNodesRelatedToModule(localIdx)
	emit_signal("module_removed", localIdx, moduleData.module)
	modulesQueuedToRemove.append(moduleData.module)
	installedModules.erase(hashedLocalIdx)
	recalculateAvailableIdxes()
	
	if emitSignal == true:
		emit_signal("machine_state_changed")

func getFloodedModulesWithoutOne(beginLocalIdx : Vector2, ignoreIdx : Vector2):
	var hashedIgnoreIdx = hashIdx(ignoreIdx)
	var hashedIdx = hashIdx(beginLocalIdx)
	var module = installedModules[hashedIdx]
	var floodedModules = {}
	floodedModules[hashedIdx] = module
	_getFloodedModulesWithoutOne(module, hashedIgnoreIdx, floodedModules)
	return floodedModules
	
func _getFloodedModulesWithoutOne(module, hashedIgnoreIdx, floodedModules):
	
	var OFFSETS = [
		Vector2(0, -1),
		Vector2(1, 0),
		Vector2(0, 1),
		Vector2(-1, 0)
	]
	
	for offset in OFFSETS:
		var idx = offset + module.localIdx
		if module.availableIdxes.has(idx):
			var hashedIdx = hashIdx(offset + module.localIdx)
			if hashedIdx != hashedIgnoreIdx:
				var installedModule = installedModules.get(hashedIdx)
				if not floodedModules.has(hashedIdx) and installedModule != null:
					floodedModules[hashedIdx] = installedModule
					_getFloodedModulesWithoutOne(installedModule, hashedIgnoreIdx, floodedModules)

func _forceDetach(localIdx : Vector2, emitSignal = true):
	
	var hashedLocalIdx = hashIdx(localIdx)
	if not installedModules.has(hashedLocalIdx):
		return
		
	var modulesToRemove = []
	if localIdx != Vector2(0, 0):
		var modulesConnectedToCore = getFloodedModulesWithoutOne(Vector2(0, 0), localIdx)
		for moduleId in installedModules.keys():
			if not modulesConnectedToCore.has(moduleId):
				var moduleToRemove = installedModules[moduleId]
				var moduleToRemoveLocalIdx = moduleToRemove.localIdx
				processor.removeNodesRelatedToModule(moduleToRemoveLocalIdx)
				modulesToRemove.append(moduleToRemove)
	else:
		modulesToRemove = installedModules.values()
	
	for moduleToRemove in modulesToRemove:
		emit_signal("module_removed", moduleToRemove.localIdx, moduleToRemove.module)
		modulesQueuedToRemove.append(moduleToRemove.module)
		installedModules.erase(hashIdx(moduleToRemove.localIdx))
	
	if localIdx == Vector2(0, 0):
		emit_signal("machine_removed")
		removeMachine = true
		return
		
	recalculateAvailableIdxes()
	
	emit_signal("machine_state_changed")
	

func canAttachModule(moduleId : String, localIdx : Vector2, rot := 0):
	return checkIfIdxAvailable(localIdx) and isAnyConnectionAvailable(moduleId, localIdx, rot)

func attachModule(moduleId : String, localIdx : Vector2, rot := 0, emitSignal = true): #local idx
	
	if not checkIfIdxAvailable(localIdx):
		printerr("Unavailable module idx!")
		push_error("Unavailable module idx!")
		return

	if not isAnyConnectionAvailable(moduleId, localIdx, rot):
		push_error("No available connection for this module!")
		printerr("No available connection for this module!")
		return
		
	var offsetsIdForConnections = getOffsetsIdForAvailableConnections(moduleId, rot)
	var availableConnections = getAvailableConnections(moduleId, localIdx, rot)
	var availableIdxes = getAvailableIdxes(moduleId, localIdx, rot)

	var newModule = MODULES[moduleId].tscn.instance()
	var hashedIdx = hashIdx(localIdx)
	installedModules[hashedIdx] = {
		'module': newModule,
		'localIdx': localIdx,
		'rot': rot,
		'availableConnections': availableConnections, # offsets
		'availableIdxes': availableIdxes # offsets
	}

	modules.add_child(newModule)
	newModule.position = level.getPosFromCellIdx(localIdx)
	newModule.setupModule(self, localIdx, rot)
	newModule.connect("module_destroyed", self, "onModuleDestroyed")

	removeAvailableIdx(localIdx)
	for offsetId in offsetsIdForConnections: 
		addAvailableIdx(OFFSETS[(offsetId)%4] + localIdx)
	
#	_recalculateViewportSize()

	if emitSignal == true:
		emit_signal("machine_state_changed")
		
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
#		draw_rect(Rect2(rectPos, level.getCellSize()), Color.wheat, false, 1.0)
#		print(rectPos)
#
#	for idx in getAvailableGlobalFreeSlots():
#		var pos = level.getPosFromCellIdx(convertToLocalIdx(idx)) + level.getCellSize() * 0.5
#		draw_circle(pos, 6.0, Color.wheat)

func hashIdx(idx : Vector2) -> int:
	var x = idx.x
	var y = idx.y
	var a = -2*x-1 if x < 0 else 2 * x
	var b = -2*y-1 if y < 0 else 2 * y
	return (a + b) * (a + b + 1) * 0.5 + b

############### Outline

#func setOutline(width : float, color := Color.white):
#	$VC.material.set_shader_param('width', width)
#	$VC.material.set_shader_param('outline_color', color)
