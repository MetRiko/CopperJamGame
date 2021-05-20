extends Node2D

onready var level = Game.level

const MODULES = {
	'dpad_module': {
		'tscn': preload("res://Machine/Modules/DPadModule.tscn"),
		'connections': ['left', 'right', 'up', 'down']
	},
	'empty_module': {
		'tscn': preload("res://Machine/Modules/EmptyModule.tscn"),
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

func getPossibleConnectionsForModule(moduleId : String, rot : int):
	return [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]

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

func getModuleFromLocalIdx(localIdx):
	var hashedLocalIdx = hashIdx(localIdx)
	var module = installedModules.get(hashedLocalIdx).module
	return module
	
############### Core
	
func _ready():
	for module in $Modules.get_children():
		module.queue_free()

func setupPos(globalIdx : Vector2):
	baseGlobalIdx = globalIdx
	global_position = level.getPosFromCellIdx(globalIdx)
	print(global_position)
	addAvailableIdx(Vector2(0, 0))

############### Building

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
	moduleData.module.queue_free()
	installedModules.erase(hashedLocalIdx)
	recalculateAvailableIdxes()

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

	$Modules.add_child(newModule)
	newModule.setupModule(self, localIdx)
	newModule.position = level.getPosFromCellIdx(localIdx)
	removeAvailableIdx(localIdx)
	for offsetId in offsetsIdForConnections: 
		addAvailableIdx(OFFSETS[(offsetId)%4] + localIdx)
		
func getLocalMouseIdx():
	return level.getCellIdxFromPos(get_global_mouse_position()) - baseGlobalIdx

func _unhandled_input(event):
	if event.is_action_pressed("LMB"):
		var mouseIdx = getLocalMouseIdx()
		var hashedMouseIdx = hashIdx(mouseIdx)
		if hashedMouseIdx in availableIdxes:
			if not level.isObstacle(mouseIdx + baseGlobalIdx):
				attachModule('empty_module', mouseIdx)
	if event.is_action_pressed("RMB"):
		var mouseIdx = getLocalMouseIdx()
		var hashedMouseIdx = hashIdx(mouseIdx)
		if hashedMouseIdx in installedModules:
			detachModule(mouseIdx)

func _process(delta):
	update()

func _draw():
	var mouseIdx = getLocalMouseIdx()
	var hashedMouseIdx = hashIdx(mouseIdx)
	if hashedMouseIdx in availableIdxes:
		var rectPos = level.getPosFromCellIdx(mouseIdx)
		draw_rect(Rect2(rectPos, level.tilemap.cell_size), Color.wheat, false, 1.0)
	
	for idx in availableIdxes.values():
		var globalIdx = baseGlobalIdx + idx
		if not level.isObstacle(globalIdx):
			var pos = level.getPosFromCellIdx(globalIdx) - global_position + level.tilemap.cell_size * 0.5
			draw_circle(pos, 6.0, Color.wheat)

func hashIdx(idx : Vector2) -> int:
	var x = idx.x
	var y = idx.y
	var a = -2*x-1 if x < 0 else 2 * x
	var b = -2*y-1 if y < 0 else 2 * y
	return (a + b) * (a + b + 1) * 0.5 + b

