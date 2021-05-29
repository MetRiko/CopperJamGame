extends Node2D

signal machine_moved

onready var level = Game.level
onready var machine = get_parent()

var currentRotation = 0

const MOVES = [
	Vector2(1, 0),
	Vector2(0, 1),
	Vector2(-1, 0),
	Vector2(-0, -1)
]

#func _input(event):
#	if event.is_action_pressed("ui_up"):
#		move(Vector2(0, -1))
#	if event.is_action_pressed("ui_down"):
#		move(Vector2(0, 1))
#	if event.is_action_pressed("ui_left"):
#		move(Vector2(-1, 0))
#	if event.is_action_pressed("ui_right"):
#		move(Vector2(1, 0))

func canMove(offset : Vector2):
	for installedModule in machine.installedModules.values():
		var localIdx = installedModule.localIdx
		var globalIdx = machine.baseGlobalIdx + localIdx + offset
		var localIdxAfterMove = installedModule.localIdx + offset
		var hashedLocalIdxAfterMove = machine.hashIdx(localIdxAfterMove)
		if not level.isFreeSpace(globalIdx) and not machine.installedModules.has(hashedLocalIdxAfterMove):
			return false
	return true

func rotateCC():
	var oldRot = currentRotation * 90
	currentRotation = (currentRotation + 1) % 4
	_updateRotation(oldRot, currentRotation*90)
	
func rotateC():
	var oldRot = currentRotation * 90
	currentRotation = (currentRotation - 1 + 4) % 4
	_updateRotation(oldRot, currentRotation*90)

func _updateRotation(currRot, targetRot):
	if currRot == 270 and targetRot == 0:
		targetRot = 270 + 90
	elif currRot == 0 and targetRot == 270:
		targetRot = -90

func moveForward():
	return move(MOVES[currentRotation])

func _playMoveAnimation(targetPos):
	$Tween.interpolate_property(machine, "global_position", machine.global_position, targetPos, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")

var nextMove = null

func _ready():
	Game.beatController.connect("beat", self, "onBeat")

func onBeat():
	if nextMove != null:
		var oldCellIdx = machine.baseGlobalIdx
		machine.baseGlobalIdx += nextMove
		var targetPos = level.getPosFromCellIdx(machine.baseGlobalIdx)
		_playMoveAnimation(targetPos)
		nextMove = null
		yield($Tween, "tween_completed")
		emit_signal("machine_moved", oldCellIdx, machine.baseGlobalIdx) #from -> to

func move(offset : Vector2):

	var oldCellIdx = machine.baseGlobalIdx
	var targetCellIdx = machine.baseGlobalIdx + offset
	var targetCell = level.getCellType(targetCellIdx)
	
	if not canMove(offset):
		nextMove = null
		return {
			success = false, 
			targetCellIdx = targetCellIdx, 
			targetCell = targetCell
		}
	
	nextMove = offset
	return {
		success = true, 
		targetCellidx = targetCellIdx, 
		targetCell = targetCell
	}
	
#
#func moveRight():
#	move()
