extends Node2D

class_name ModuleBase

var _machine = null
var _localIdx := Vector2()

var _tween = null

var _instructions = null 

# Animations

func playAnimationPulse(node):
	_tween.interpolate_property(node, "global_scale", Vector2(1.0, 1.0), Vector2(1.4, 1.4), 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	_tween.start()
	_tween.interpolate_property(node, "global_scale", Vector2(1.4, 1.4), Vector2(1.0, 1.0), 0.2, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()

func playAnimationRotateC(node):
	var currentAngle = fmod(node.global_rotation_degrees, 360.0)
	_tween.interpolate_property(node, "global_rotation_degrees", currentAngle, currentAngle - 90.0, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	_tween.start()
	
func playAnimationRotateCC(node):
	var currentAngle = fmod(node.global_rotation_degrees, 360.0)
	_tween.interpolate_property(node, "global_rotation_degrees", currentAngle, currentAngle + 90.0, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	_tween.start()
	
# Getters

func getMachine():
	return _machine

func getLocalIdx():
	return _localIdx
	
func getGlobalIdx():
	return _localIdx + _machine.getGlobalIdx()

# Core

func setupModule(machine, localIdx):
	self._localIdx = localIdx
	self._machine = machine

func callInstruction(instructionId):
	var instruction = _instructions.get(instructionId)
	if instruction != null:
		call(instruction.functionName)
	else:
		print("Unknown instruction")

func _setupNode(derivedNode, instructions):
	_instructions = instructions
	_tween = Tween.new()
	print(derivedNode.name)
	derivedNode.add_child(_tween)
