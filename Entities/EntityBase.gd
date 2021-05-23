extends Node2D

class_name EntityBase

signal moved

onready var tilemap = Game.tilemap
onready var level = Game.level

var currentCellIdx := Vector2()

var currentRotation = 0

const MOVES = [
	Vector2(1, 0),
	Vector2(0, 1),
	Vector2(-1, 0),
	Vector2(-0, -1)
]

func getCurrentCellIdx():
	return currentCellIdx

func getCellIdx(pos : Vector2):
	return level.getCellIdxFromPos(pos)

func getCellPos(cellIdx : Vector2):
	return level.getPosFromCellIdx(cellIdx)

func setupPosition(globalPosition):
	global_position = globalPosition
	currentCellIdx = getCellIdx(globalPosition)

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
	$Tween.interpolate_property($Sprite, "global_rotation_degrees", currRot, targetRot, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	playAnimationPulse($Sprite)

func moveForward():
	return move(MOVES[currentRotation])

func playAnimationPulse(node):
	$Tween.interpolate_property(node, "scale", Vector2(0.125, 0.125), Vector2(0.125 * 1.3, 0.125 * 1.3), 0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	$Tween.interpolate_property(node, "scale", Vector2(0.125 * 1.3, 0.125 * 1.3), Vector2(0.125, 0.125), 0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()

func move(offset : Vector2):
	
	var oldCellIdx = currentCellIdx
	var targetCellIdx = currentCellIdx + offset
	var targetCell = tilemap.get_cell(targetCellIdx.x, targetCellIdx.y)
	
	if not level.isCellIdAnyFloor(targetCell):
		return {
			success = false, 
			targetCellIdx = targetCellIdx, 
			targetCell = targetCell
		}
	
	currentCellIdx.x += offset.x
	currentCellIdx.y += offset.y
	var targetPos = getCellPos(currentCellIdx)
	$Tween.interpolate_property(self, "global_position", global_position, targetPos, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	playAnimationPulse($Sprite)
	
	return {
		success = true, 
		targetCellidx = targetCellIdx, 
		targetCell = targetCell
	}
	
	emit_signal("moved", oldCellIdx, targetCellIdx) #from -> to
	
#
#func moveRight():
#	move()
