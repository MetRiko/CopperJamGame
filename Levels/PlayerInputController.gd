extends Node2D

signal state_changed
signal module_to_attach_changed
signal module_selected
signal hovered_object_changed
signal new_machine_placed
signal module_attached
signal module_detached

onready var tilemap = Game.tilemap
onready var level = Game.level
onready var gui = Game.gui
onready var nodeEditor = Game.nodeEditor
onready var player = level.getPlayer()

enum {
	NORMAL_STATE,
	BUILDING_STATE
}

enum {
	HOVERED_OBSTACLE,
	HOVERED_MODULE,
	HOVERED_ENEMY,
	HOVERED_JUST_FLOOR,
}

var state = null

var hoveredObject = HOVERED_JUST_FLOOR

var currentSelectedModuleIdx = Vector2()
var currentMouseIdx = Vector2(-100, -100)

var latestHoveredModule = null
var selectedModule = null

var latestNewMachine = null

var moduleToAttach = null
var rotOfModuleToAttach = 0

# Getters

func getMouseIdx():
	return currentMouseIdx

func getSelectedModule():
	return selectedModule

func getSelectedMachine():
	if selectedModule != null and is_instance_valid(selectedModule):
		var machine = selectedModule.getMachine()
		if is_instance_valid(machine):
			return machine
	return null

func getHoveredMachine():
	if latestHoveredModule != null and is_instance_valid(latestHoveredModule):
		var machine = latestHoveredModule.getMachine()
		if is_instance_valid(machine):
			return machine
	return null

func getHoveredModule():
	return latestHoveredModule

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
	Game.beatController.connect("after_beat", self, "onAfterBeat")
	changeStateToNormal()

func _process(delta):
	var mouseIdx = level.getCellIdxFromMousePos()
	if mouseIdx != currentMouseIdx:
		currentMouseIdx = mouseIdx
		_hoverObject(mouseIdx)

func onAfterBeat():
	var mouseIdx = level.getCellIdxFromMousePos()
	_hoverObject(mouseIdx)

func _hoverObject(idx):

	var isObstacle = level.isObstacle(idx)
	if isObstacle:
		_hoverObstacle()
		emit_signal("hovered_object_changed", hoveredObject)
		return
	
	var machine = level.getMachineFromIdx(idx)
	if machine != null:
		_hoverModule(machine.getModuleFromLocalIdx(machine.convertToLocalIdx(idx)))
		emit_signal("hovered_object_changed", hoveredObject)
		return
	else:
		_unhoverLatestModule()

	var isEnemy = level.getEntityFromIdx(idx) != null
	if isEnemy:
		_hoverEnemy()
		emit_signal("hovered_object_changed", hoveredObject)
		return
	
	_hoverFloor()

	emit_signal("hovered_object_changed", hoveredObject)

############### Hovering

func getHoveredObject():
	return hoveredObject

func isHoveredObstacle():
	return hoveredObject == HOVERED_OBSTACLE

func isHoveredModule():
	return hoveredObject == HOVERED_MODULE

func isHoveredEnemy():
	return hoveredObject == HOVERED_ENEMY

func isHoveredFloor():
	return hoveredObject == HOVERED_JUST_FLOOR

func _unhoverLatestModule():
	_hoverModule(null)

func _hoverObstacle():
	hoveredObject = HOVERED_OBSTACLE

func _hoverModule(module):
	hoveredObject = HOVERED_MODULE

	if module != latestHoveredModule:

		if latestHoveredModule != null and is_instance_valid(latestHoveredModule):
			if latestHoveredModule != selectedModule:
				latestHoveredModule.modulate = Color(1.0, 1.0, 1.0, 1.0)
		
#			if (module != null and latestHoveredModule.getMachine() != module.getMachine()) or module == null:
#				latestHoveredModule.getMachine().setOutline(0.0)

	if module != null and module != selectedModule:
#		module.getMachine().setOutline(1.0, Color(1.0, 1.0, 1.0, 0.6))
		module.modulate = Color(1.2, 1.2, 1.2, 1.0)

	latestHoveredModule = module

func _hoverEnemy():
	hoveredObject = HOVERED_ENEMY

func _hoverFloor():
	hoveredObject = HOVERED_JUST_FLOOR

	# red or green gizmo if can attach module TODO

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

	# on module - select/unselect module
	if hoveredObject == HOVERED_MODULE:
		var module = level.getModuleFromIdx(currentMouseIdx)
		_selectModule(module)
	else:
		_unselectModule()

func _leftClickWhenBuildingState(): 

	# without selected module to attach
	if moduleToAttach == null:

		# on module - select/unselect module
		if hoveredObject == HOVERED_MODULE:
			var module = level.getModuleFromIdx(currentMouseIdx)
			_selectModule(module)
		else:
			_unselectModule()

		# on floor - place/replace new machine - FEATURE DISABLED
		# if hoveredObject == HOVERED_JUST_FLOOR:
		# 	_placeNewMachine()

	# with selected module to attach
	else:
		# on module - (only) select module
		if hoveredObject == HOVERED_MODULE:
			var module = level.getModuleFromIdx(currentMouseIdx)
			_selectModule(module)

		# on floor - attach module / create new machine
		elif hoveredObject == HOVERED_JUST_FLOOR:
			
			if not is_instance_valid(selectedModule):
				selectedModule = null

			# not selected module - create new machine
			if selectedModule == null:
				_placeNewMachine()
				_attachSelectedModule(currentMouseIdx)
				
			# selected module - attach module / unselect module 
			elif selectedModule != null and is_instance_valid(selectedModule):
				var machine = selectedModule.getMachine()
				var localIdx = machine.convertToLocalIdx(currentMouseIdx)
				var isAttachable = machine.canAttachModule(moduleToAttach, localIdx, rotOfModuleToAttach)
				if isAttachable:
					_attachSelectedModule(currentMouseIdx)
				else:
					_unselectModule()
					

func _rightClickWhenNormalState(): 
	
	# on floor - move player @TODO
	if hoveredObject == HOVERED_JUST_FLOOR or hoveredObject == HOVERED_ENEMY:
		player.autoMoveToIdx(currentMouseIdx)

func _rightClickWhenBuildingState(): # remove module / 
	
	# on not module - cancel new machine
	if hoveredObject != HOVERED_MODULE:
		_cancelNewMachine()
		deselectModuleToAttach()

	# on module - remove module
	else:
		var module = level.getModuleFromIdx(currentMouseIdx)
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
	latestNewMachine = level.createNewMachine(currentMouseIdx)
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
			Game.beatController.pauseGame()
		elif newState == BUILDING_STATE:
			Game.beatController.resumeGame()

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
