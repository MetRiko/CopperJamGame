extends Node2D

signal state_changed
signal module_to_attach_changed
signal module_selected
signal new_machine_placed
signal module_attached
signal module_detached

onready var level = Game.level
onready var player = level.getPlayer()

onready var hoverCtrl = get_parent().get_node("ObjectHoverController")
onready var playerRangeCtrl = get_parent().get_node("PlayerRangeController")

enum {
	NORMAL_STATE,
	BUILDING_STATE
}

var state = null

var currentSelectedModuleIdx = Vector2()

var selectedModule = null

var latestNewMachine = null

var moduleToAttach = null
var rotOfModuleToAttach = 0

# Getters

func getSelectedModule():
	return selectedModule

func getSelectedMachine():
	if selectedModule != null and is_instance_valid(selectedModule):
		var machine = selectedModule.getMachine()
		if is_instance_valid(machine):
			return machine
	return null

func getIdModuleToAttach():
	return moduleToAttach

func getRotModuleToAttack():
	return rotOfModuleToAttach

func isModuleToAttachSelected():
	return moduleToAttach != null

func isModuleSelected():
	return selectedModule != null and is_instance_valid(selectedModule)

# Core

func enablePlayerInput():
	set_process_unhandled_input(true)
	set_process(true)
	
func disablePlayerInput():
	set_process_unhandled_input(false)
	set_process(false)

func _ready():
	playerRangeCtrl.connect("player_range_changed", self, "onPlayerRangeChanged")
	changeStateToNormal()

func onPlayerRangeChanged():
	return
	if selectedModule != null and is_instance_valid(selectedModule):
		var isSelectedModuleInPlayerRange = playerRangeCtrl.isIdxInPlayerRange(selectedModule.getGlobalIdx())
		if isSelectedModuleInPlayerRange == false:
			_unselectModule()

############### Player input

func _unhandled_input(event):

	if event.is_action_pressed("space"):
		if state == NORMAL_STATE:
			_changeState(BUILDING_STATE)
		elif state == BUILDING_STATE:
			_changeState(NORMAL_STATE)

	# if event.is_action_released("space"):
	# 	if state == BUILDING_STATE:
	# 		_changeState(NORMAL_STATE)

	if event.is_action_pressed("LMB"):

		if state == NORMAL_STATE:
			_leftClickWhenNormalState()
		elif state == BUILDING_STATE:
			_leftClickWhenBuildingState()

	if event.is_action_pressed("RMB"):
		if state == NORMAL_STATE:
			_rightClickWhenNormalState()
		elif state == BUILDING_STATE:
			_rightClickWhenBuildingState()

	if event.is_action_pressed("rotate_left"):
		if state == BUILDING_STATE:
			_qClickWhenBuildingState()

	if event.is_action_pressed("rotate_right"):
		if state == BUILDING_STATE:
			_eClickWhenBuildingState()

func _leftClickWhenNormalState(): 

	var isMouseIdxInPlayerRange = playerRangeCtrl.isIdxInPlayerRange(hoverCtrl.getMouseIdx())
	print(isMouseIdxInPlayerRange)
	
	# on module - select/unselect module
	if hoverCtrl.isHoveredModule() and isMouseIdxInPlayerRange == true:
		var module = level.getModuleFromIdx(hoverCtrl.getMouseIdx())
		_selectModule(module)
	else:
		_unselectModule()

func _leftClickWhenBuildingState(): 

	var isMouseIdxInPlayerRange = playerRangeCtrl.isIdxInPlayerRange(hoverCtrl.getMouseIdx())

	# select module
	if hoverCtrl.isHoveredModule() and isMouseIdxInPlayerRange == true:
		var module = level.getModuleFromIdx(hoverCtrl.getMouseIdx())
		_selectModule(module)

	# without selected module to attach
	if moduleToAttach == null:

		# on module - select/unselect module
		if not hoverCtrl.isHoveredModule():
			_unselectModule()

		# on floor - place/replace new machine - FEATURE DISABLED
		# if hoveredObject == HOVERED_JUST_FLOOR:
		# 	_placeNewMachine()

	# with selected module to attach
	else:

		# on floor - attach module / create new machine
		if hoverCtrl.isHoveredFloor() and isMouseIdxInPlayerRange == true:

			# not selected module - create new machine
			if selectedModule == null or not is_instance_valid(selectedModule):
				selectedModule = null
				_placeNewMachine()
				_attachSelectedModule(hoverCtrl.getMouseIdx())
				
			# selected module - attach module / unselect module 
			elif selectedModule != null and is_instance_valid(selectedModule):
				var machine = selectedModule.getMachine()
				var localIdx = machine.convertToLocalIdx(hoverCtrl.getMouseIdx())
				var isAttachable = machine.canAttachModule(moduleToAttach, localIdx, rotOfModuleToAttach)
				if isAttachable:
					_attachSelectedModule(hoverCtrl.getMouseIdx())
				else:
					_unselectModule()
					

func _rightClickWhenNormalState(): 
	
	# on floor - move player @TODO
	if hoverCtrl.isHoveredFloor() or hoverCtrl.isHoveredEnemy():
		player.autoMoveToIdx(hoverCtrl.getMouseIdx())

func _rightClickWhenBuildingState(): # remove module / 
	
	# on not module - cancel new machine
	if not hoverCtrl.isHoveredModule():
		_cancelNewMachine()
		deselectModuleToAttach()

	# on module - remove module
	else:
		var module = level.getModuleFromIdx(hoverCtrl.getMouseIdx())
		_removeModule(module)

func _qClickWhenBuildingState():
	var newRot = (rotOfModuleToAttach + 3) % 4
	_rotateModuleToAttach(newRot)

func _eClickWhenBuildingState():
	var newRot = (rotOfModuleToAttach + 1) % 4
	_rotateModuleToAttach(newRot)

############### Actions

func _rotateModuleToAttach(newRot):
	rotOfModuleToAttach = newRot
	emit_signal("module_to_attach_changed", moduleToAttach, rotOfModuleToAttach)

func _attachSelectedModule(idx : Vector2):
	if moduleToAttach != null:
		if selectedModule != null and is_instance_valid(selectedModule):
			var machine = selectedModule.getMachine()
			var localIdx = machine.convertToLocalIdx(idx)
			if machine.canAttachModule(moduleToAttach, localIdx, rotOfModuleToAttach):
				machine.attachModule(moduleToAttach, localIdx, rotOfModuleToAttach)
				emit_signal("module_attached", moduleToAttach)
			else:
				pass # red pulse effect on gizmo TODO
		elif latestNewMachine != null and is_instance_valid(latestNewMachine):
			var localIdx = latestNewMachine.convertToLocalIdx(idx)
			if latestNewMachine.canAttachModule(moduleToAttach, localIdx, rotOfModuleToAttach):
				latestNewMachine.attachModule(moduleToAttach, localIdx, rotOfModuleToAttach)
				var module = latestNewMachine.getModuleFromLocalIdx(localIdx)
				_selectModule(module)
				emit_signal("module_attached", moduleToAttach)
			else:
				pass # red pulse effect on gizmo TODO

func deselectModuleToAttach():
	selectModuleToAttach(null)

func selectModuleToAttach(moduleId):
	if moduleId != moduleToAttach:
		moduleToAttach = moduleId
		emit_signal("module_to_attach_changed", moduleId, rotOfModuleToAttach)

func _removeModule(module):
	if module != null and is_instance_valid(module):
		var machine = module.getMachine()
		if machine.canDetachModule(module.getLocalIdx()):
			var moduleId = module.getModuleId()
			machine.detachModule(module.getLocalIdx())
			emit_signal("module_detached", moduleId)
		else:
			pass # red pulse animation from module

func _unselectModule():
	_selectModule(null)

func _selectModule(module):
	if selectedModule != null and is_instance_valid(selectedModule) and module != selectedModule:
		selectedModule.modulate = Color(1.0, 1.0, 1.0, 1.0)
		
		var machine = selectedModule.getMachine()
		if is_instance_valid(machine) and machine.getModulesCount() == 0:
			machine.queue_free()
			
	_cancelNewMachine()
		
	if module != null:
		module.modulate = Color(1.4, 1.4, 1.4, 1.0)

	selectedModule = module
	emit_signal("module_selected", module)

func _placeNewMachine():
	_cancelNewMachine(false)
	latestNewMachine = level.createNewMachine(hoverCtrl.getMouseIdx())
	emit_signal("new_machine_placed", latestNewMachine)

func _cancelNewMachine(emitSignal = true):
	if latestNewMachine != null and is_instance_valid(latestNewMachine):
		if latestNewMachine.getModulesCount() == 0:
			latestNewMachine.queue_free()
	latestNewMachine = null
	
	if emitSignal == true:
		emit_signal("new_machine_placed", null)

############### Changing states

func _changeState(newState):
	if state != newState:
		state = newState
		if newState == NORMAL_STATE:
			deselectModuleToAttach()
			_cancelNewMachine()
			Game.beatController.resumeGame()
		elif newState == BUILDING_STATE:
			Game.beatController.pauseGame()

		emit_signal("state_changed", newState)

func changeStateToNormal():
	_changeState(NORMAL_STATE)

func changeStateToBuilding():
	_changeState(BUILDING_STATE)

############### Checking states

func isBuildingState():
	return state == BUILDING_STATE

func isNormalState():
	return state == NORMAL_STATE
