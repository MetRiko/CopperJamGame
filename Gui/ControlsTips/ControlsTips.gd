extends Control


onready var level = Game.level
onready var pic = level.getPlayerInputController()
onready var allTips = $AllTips

func _ready():
	pic.connect("state_changed", self, "onStateChanged")
	pic.connect("module_to_attach_changed", self, "onModuleToAttachChanged")

func setTipsSet(id):
	for tips in allTips.get_children():
		tips.visible = false
	
	allTips.get_child(id).visible = true

func detectTipState():
	var isModuleToAttach = pic.isModuleToAttachSelected()
	if pic.isNormalState():
		setTipsSet(0)
	elif pic.isBuildingState():
		if isModuleToAttach:
			setTipsSet(2)
		else:
			setTipsSet(1)

func onStateChanged(state):
	detectTipState()
	
func onModuleToAttachChanged(moduleId, rot):
	detectTipState()
		
