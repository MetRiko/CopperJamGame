extends Button

onready var playerInputController = Game.level.getPlayerInputController()

var locked := true

var moduleData = null

func lock():
	locked = true
	modulate.r = 2.0

func unlock():
	locked = false
	modulate.r = 1.0

func _ready():
	lock()

func getModuleData():
	return moduleData

func setModuleData(moduleData):
	self.moduleData = moduleData
	if moduleData != null:
		$Sprite.visible = true
		var frameId = moduleData.get('frameId')
		if frameId != null:
			$Sprite.frame = moduleData.frameId
		else:
			$Sprite.frame = 0 # Unknown module icon TODO
	else:
		$Sprite.visible = false

func _pressed():
	if locked == false and moduleData != null:
		playerInputController.selectModuleToAttach(moduleData.moduleId)
		# change value of copper TODO
