extends Node2D

onready var level = Game.level

const MODULES = {
	'dpad_module': preload("res://Machine/Modules/DPadModule.tscn"),
	'empty_module': preload("res://Machine/Modules/EmptyModule.tscn")
}

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


func getGlobalIdx():
	return baseGlobalIdx

func justCallInstruction(localModuleIdx : Vector2, instructionId : String):
	$Processor.justCallInstruction(localModuleIdx, instructionId)

func canMove(offset : Vector2):
	return $Movement.canMove(offset)

func move(offset : Vector2):
	$Movement.move(offset)

func _ready():
	for module in $Modules.get_children():
		module.queue_free()

func getModuleFromLocalIdx(localIdx):
	var hashedLocalIdx = hashIdx(localIdx)
	var module = installedModules.get(hashedLocalIdx).module
	return module

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

func setupPos(globalIdx : Vector2):
	baseGlobalIdx = globalIdx
	global_position = level.getPosFromCellIdx(globalIdx)
	print(global_position)
	addAvailableIdx(Vector2(0, 0))

func checkIfIdxAvailable(idx : Vector2):
	var hashedIdx = hashIdx(idx)
	return availableIdxes.has(hashedIdx)

func attachModule(moduleId : String, localIdx : Vector2): #local idx
	
	if not checkIfIdxAvailable(localIdx):
		printerr("Unavailable module idx!")
		print_stack()
		return 
		
	
	var newModule = MODULES[moduleId].instance()
	var hashedIdx = hashIdx(localIdx)
	installedModules[hashedIdx] = {
		'module': newModule,
		'localIdx': localIdx
	}
	
	$Modules.add_child(newModule)
	newModule.setupModule(self, localIdx)
	newModule.position = level.getPosFromCellIdx(localIdx)
	removeAvailableIdx(localIdx)
	addAvailableIdx(localIdx + Vector2(0, 1))
	addAvailableIdx(localIdx + Vector2(0, -1))
	addAvailableIdx(localIdx + Vector2(1, 0))
	addAvailableIdx(localIdx + Vector2(-1, 0))

func getLocalMouseIdx():
	return level.getCellIdxFromPos(get_global_mouse_position()) - baseGlobalIdx

func _unhandled_input(event):
	if event.is_action_pressed("LMB"):
		var mouseIdx = getLocalMouseIdx()
		var hashedMouseIdx = hashIdx(mouseIdx)
		if hashedMouseIdx in availableIdxes:
			if not level.isObstacle(mouseIdx + baseGlobalIdx):
				attachModule('empty_module', mouseIdx)

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

func hashIdx(idx):
	var x = idx.x
	var y = idx.y
	var a = -2*x-1 if x < 0 else 2 * x
	var b = -2*y-1 if y < 0 else 2 * y
	return (a + b) * (a + b + 1) * 0.5 + b

