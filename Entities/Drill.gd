extends Node2D

onready var tilemap = Game.tilemap

var currentCellIdx := Vector2()

var currentRotation = 0

const MOVES = [
	Vector2(1, 0),
	Vector2(0, 1),
	Vector2(-1, 0),
	Vector2(-0, -1)
]

func _input(event):
	if event.is_action_pressed('num1'):
		rotateC()
	if event.is_action_pressed('num2'):
		moveForward()
	if event.is_action_pressed('num3'):
		rotateCC()

func getCellIdx(pos : Vector2):
	return tilemap.world_to_map(pos)

func getCellPos(cellIdx : Vector2):
	return tilemap.map_to_world(cellIdx)

func _ready():
	currentCellIdx = getCellIdx(global_position)

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
	$Anim.play("Move", -1, 5.0)

func moveForward():
	move(MOVES[currentRotation])

func move(offset):
	currentCellIdx.x += offset.x
	currentCellIdx.y += offset.y
	var targetPos = getCellPos(currentCellIdx)
	$Tween.interpolate_property(self, "global_position", global_position, targetPos, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	$Anim.play("Move", -1, 5.0)
	
#
#func moveRight():
#	move()
