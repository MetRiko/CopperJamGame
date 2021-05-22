extends Node2D

class_name ModuleBase

var _machine = null
var _localIdx := Vector2()

var _tween = null

var _instructions = {}
var _instructionsOrder = []

var _rotation = 0
var _moduleId := ''

# Animations

func playAnimationPulse(node):
	_tween.interpolate_property(node, "global_scale", Vector2(1.0, 1.0), Vector2(1.4, 1.4), 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	_tween.start()
	_tween.interpolate_property(node, "global_scale", Vector2(1.4, 1.4), Vector2(1.0, 1.0), 0.2, Tween.TRANS_SINE, Tween.EASE_IN)
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

func getInstructions():
	return _instructions
	
func getInstructionsOrder():
	return _instructionsOrder

func getModuleId():
	return _moduleId

func getCurrentRotation():
	return _rotation

func getMachine():
	return _machine

func getLocalIdx():
	return _localIdx
	
func getGlobalIdx():
	return _localIdx + _machine.getGlobalIdx()

# Core

#func getPossibleConnectionsIdxex():

func isConditionInstruction(instructionId):
	var instruction = _instructions.get(instructionId)
	return instruction != null and instruction.has('conditionFunctionName')

func setupModule(machine, localIdx):
	self._localIdx = localIdx
	self._machine = machine

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
