extends Node

signal copper_value_changed
signal insufficient_copper

onready var level = Game.level
onready var pic = level.getPlayerInputController()

const ALL_SHOP_CONTENT = preload("res://Gui/AllShopContent.gd").ALL_SHOP_CONTENT
var modules = ALL_SHOP_CONTENT
var current := 200

func _ready():
	current = 200
	pic.connect("module_attached", self, "onModuleAttached")
	pic.connect("module_detached", self, "onModuleDetached")

func addCopper(value):
	setCopper(current + value)

func setCopper(value):
	emit_signal("copper_value_changed", value)
	current = value

func onModuleAttached(moduleId):
	if hasEnoughCopper(moduleId):
		var currentModule = getModule(moduleId)
		addCopper(-currentModule.cost)
	else:
		emit_signal("insufficient_copper")

func onModuleDetached(moduleId):
	var currentModule = getModule(moduleId)
	addCopper(floor(currentModule.cost * 0.7))

func getModule(moduleId):
	for module in modules:
		if module.moduleId == moduleId:
			return module
	return null

func hasEnoughCopper(moduleId):
	var currentModule = getModule(moduleId)
	if current > currentModule.cost:
		return true
	else: 
		return false
