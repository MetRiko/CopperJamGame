extends Node2D

class_name ModuleBase

const healthControllerTscn = preload("res://Machine/ModuleHealthController.tscn")

var _machine = null
var _localIdx := Vector2()

var _tween = null

var _instructions = {}
var _instructionsOrder = []

var _rotation := 0
var _moduleId := ''
var _healthController = null

var _rot := 0

const OFFSETS = [
	Vector2(0, -1),
	Vector2(1, 0),
	Vector2(0, 1),
	Vector2(-1, 0)
]

# Animations

func playAnimationPulse(node):
	_tween.interpolate_property(node, "scale", Vector2(0.125, 0.125), Vector2(0.125 * 1.3, 0.125 * 1.3), 0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
	_tween.start()
	_tween.interpolate_property(node, "scale", Vector2(0.125 * 1.3, 0.125 * 1.3), Vector2(0.125, 0.125), 0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
	_tween.start()

func playAnimationRotate(node, startRot, targetRot):
	if startRot == 270 and targetRot == 0:
		targetRot = 270 + 90
	elif startRot == 0 and targetRot == 270:
		targetRot = -90
	$Tween.interpolate_property(node, "global_rotation_degrees", startRot, targetRot, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	
func playAnimationRotateCC(node):
	var currentAngle = fmod(node.global_rotation_degrees, 360.0)
	_tween.interpolate_property(node, "global_rotation_degrees", currentAngle, currentAngle - 90.0, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	_tween.start()
	
func playAnimationRotateC(node):
	var currentAngle = fmod(node.global_rotation_degrees, 360.0)
	_tween.interpolate_property(node, "global_rotation_degrees", currentAngle, currentAngle + 90.0, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	_tween.start()

func rotateModuleCC(node):
	var oldRot = _rotation * 90
	_rotation = (_rotation + 1) % 4
	playAnimationRotate(node, oldRot, _rotation*90)
	
func rotateModuleC(node):
	var oldRot = _rotation * 90
	_rotation = (_rotation - 1 + 4) % 4
	playAnimationRotate(node, oldRot, _rotation*90)
	
# Getters

func getForwardVector():
	return OFFSETS[_rot % 4]

func getInstructions():
	return _instructions
	
func getInstructionsOrder():
	return _instructionsOrder

func getModuleId():
	return _moduleId

func getCurrentRotation():
	return _rot

func getMachine():
	return _machine

func getLocalIdx():
	return _localIdx
	
func getGlobalIdx():
	return _localIdx + _machine.getGlobalIdx()

# Core

func doDamage(value):
	_healthController.doDamage(value)
	playAnimationPulse($Sprite)

#func getPossibleConnectionsIdxex():

func isConditionInstruction(instructionId):
	var instruction = _instructions.get(instructionId)
	return instruction != null and instruction.has('conditionFunctionName')

func onNoHealth():
	_machine.detachModule(_localIdx, true)

func clearBeforeFree():
	if is_instance_valid(_healthController):
		_healthController.queue_free()
#	_tween.interpolate_property($Sprite, 'global_rotation_degrees', global_rotation_degrees, global_rotation_degrees + 720.0, 0.8, Tween.TRANS_SINE, Tween.EASE_OUT)
#	_tween.start()
#	_tween.interpolate_property($Sprite, 'global_scale', global_scale, Vector2(0, 0), 0.8, Tween.TRANS_SINE, Tween.EASE_OUT)
#	_tween.start()

	_tween.interpolate_property($Sprite, 'global_scale', $Sprite.global_scale, Vector2(0.125 * 1.2, 0.125 * 1.2), 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	_tween.start()
	_tween.interpolate_property($Sprite, 'modulate', $Sprite.modulate, Color(3.0, 3.0, 3.0, 1.0), 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	_tween.start()
	yield(_tween, "tween_completed")
	_tween.interpolate_property($Sprite, 'modulate', $Sprite.modulate, Color(0.0, 0.0, 0.0, 0.0), 0.6, Tween.TRANS_SINE, Tween.EASE_OUT)
	_tween.start()
	_tween.interpolate_property($Sprite, 'global_scale', $Sprite.global_scale, Vector2(0.0, 0.0), 0.6, Tween.TRANS_SINE, Tween.EASE_OUT)
	_tween.start()

func _createHealthController():
	_healthController = healthControllerTscn.instance()
	_machine.healthControllers.add_child(_healthController)
	_healthController.position = position
	_healthController.global_position.x += 32.0 * 0.5
	_healthController.connect("no_health", self, "onNoHealth")

func setupModule(machine, localIdx, rot):
	self._localIdx = localIdx
	self._machine = machine
	self._rot = rot
	_createHealthController()

func callInstruction(instructionId):
	var instruction = _instructions.get(instructionId)
	if instruction != null:
		var functionName = instruction.get('functionName')
		if functionName != null:
			call(functionName)
#		else:
#			push_error('This intruction has no functionName')
		var conditionFunctionName = instruction.get('conditionFunctionName')
		if conditionFunctionName != null:
			return call(conditionFunctionName)
		return true
	else:
		print("Unknown instruction")
		return false	

func _setupNode(moduleId, derivedNode, instructions, instructionsOrder):
	_moduleId = moduleId
	_instructions = instructions
	_instructionsOrder = instructionsOrder
	
	_tween = Tween.new()
	derivedNode.add_child(_tween)
