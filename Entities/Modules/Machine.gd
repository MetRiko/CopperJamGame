extends Node2D

onready var level = Game.level

const MODULES = {
	'empty_module': preload("res://Entities/Modules/DPadModule.tscn"),
	'dpad_module': preload("res://Entities/Modules/EmptyModule.tscn")
}

var modules := []
var modulesIdxes := [] 

var availableIdxes := {} #local

var baseModule = null

var baseGlobalIdx := Vector2()

func _ready():
	$Base/DPadModule.queue_free()
	$Modules/EmptyModule.queue_free()
	$Modules/EmptyModule2.queue_free()

func addAvailableIdx(idx : Vector2):
	var hashedIdx = hashIdx(idx)
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

func attachModule(moduleId : String, idx : Vector2): #local idx
	
	if not checkIfIdxAvailable(idx):
		print("Unavailable module idx")
		return 
		
	var newModule = MODULES[moduleId].instance()
	$Modules.add_child(newModule)
	newModule.position = level.getPosFromCellIdx(idx)
	removeAvailableIdx(idx)
	modulesIdxes.append(idx)
	addAvailableIdx(idx + Vector2(0, 1))
	addAvailableIdx(idx + Vector2(0, -1))
	addAvailableIdx(idx + Vector2(1, 0))
	addAvailableIdx(idx + Vector2(-1, 0))

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

