extends Node


onready var level = Game.level
onready var pic = level.getPlayerInputConctroller()


# Called when the node enters the scene tree for the first time.
func _ready():
	pic.connect("module_attached", self, "onModuleAttached")
	pic.connect("module_detached", self, "onModuleDetached")

func addCopper(value):
	pass
#	setCopper(current + value)

func setCopper(value):
	pass
	# emit_signal("copper_changed"....

func onModuleAttached(moduleId):
	pass
	
func onModuleDetached(moduleId):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
