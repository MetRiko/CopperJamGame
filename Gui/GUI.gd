extends Control

const ALL_SHOP_CONTENT = preload("res://Gui/AllShopContent.gd").ALL_SHOP_CONTENT

onready var playerInputController = Game.level.getPlayerInputController()
onready var copperValueController = Game.level.get_node("Controllers/CopperValueController")

onready var buildModeButton = $BuildModeButton
onready var shop = $Shop
onready var buttons = $Shop/Panels/ModulesButtons/ButtonsGrid
onready var moduleName = $Shop/Panels/Description/VBoxContainer/ModuleName
onready var moduleTooltip = $Shop/Panels/Description/VBoxContainer/ModuleTooltip
onready var miedzCounter = $CopperCounter/HBoxContainer/Label
onready var moduleCost = $Shop/Panels/Cost/Label
onready var moduleCostIcon = $Shop/Panels/Cost/CopperIcon

# Core

func _ready():
	moduleCostIcon.hide()
	moduleCost.text = ""
	_initBuildModeButton()
	playerInputController.connect("state_changed", self, "onStateChanged")
	copperValueController.connect("copper_value_changed", self, "copper_value_changed")
	copperValueController.connect("insufficient_copper", self, "insufficient_copper")
	_initShopButtons()

# BuildModeButton

func _initBuildModeButton():
	buildModeButton.connect("toggled", self, "onBuildModeButtonToggled")
#	buildModeButton.connect("mouse_entered", self, "onBuildModeButtonMouseEntered")
#	buildModeButton.connect("mouse_exited", self, "onBuildModeButtonMouseExited")

func onBuildModeButtonToggled(toggled):
	if toggled == true:
		playerInputController.changeStateToBuilding()
	else:
		playerInputController.changeStateToNormal()

#func onBuildModeButtonMouseEntered():
#
#func onBuildModeButtonMouseExited():
#	if buildModeButton.pressed == false:

# Switching between states

func hideShop():
	$Tween.interpolate_property(shop, "modulate:a", 1.0, 0.0, 0.12, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	shop.hide()
	
func showShop():
	shop.show()
	shop.modulate.a = 0.0
	$Tween.interpolate_property(shop, "modulate:a", 0.0, 1.0, 0.12, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")

func onStateChanged(newState):
	if newState == playerInputController.BUILDING_STATE:
		buildModeButton.pressed = true
		showShop()
		buildModeButton.material.set_shader_param("enabled", true)
	elif newState == playerInputController.NORMAL_STATE:
		buildModeButton.pressed = false
		hideShop()
		buildModeButton.material.set_shader_param("enabled", false)

# Shop

func _initShopButtons():
	for button in buttons.get_children():
		button.hide()

	for i in range(ALL_SHOP_CONTENT.size()):
		var button = buttons.get_child(i)
		var data = ALL_SHOP_CONTENT[i]
		button.show()
		button.setModuleData(data)
		button.unlock()
		button.connect("mouse_entered", self, "onModuleButtonMouseEntered", [button])
		button.connect("mouse_exited", self, "onModuleButtonMouseExited")

func onModuleButtonMouseEntered(button):
	var data = button.getModuleData()
	if data != null:
		moduleName.text = button.getModuleData().name
		moduleTooltip.text = button.getModuleData().tooltip
		moduleCost.text = str(button.getModuleData().cost)
		moduleCostIcon.show()
	else:
		moduleName.text = ""
		moduleTooltip.text = ""
		moduleCost.text = ""
		moduleCostIcon.hide()

func onModuleButtonMouseExited():
	moduleName.text = ""
	moduleTooltip.text = ""
	moduleCost.text = ""
	moduleCostIcon.hide()

func copper_value_changed(value):
#	print(value)
	miedzCounter.text = str(value)

func insufficient_copper():
	moduleTooltip.text = "insufficient copper"




# signal module_button_pressed
# #signal tooltip_hovered

# onready var beatController = Game.beatController
# onready var menu = Game.menu
# onready var tilemap = Game.tilemap
# onready var level = get_parent().get_parent()
# onready var pauseMenu = Game.pauseMenu
# # onready var buildController = level.getBuildController()
# onready var 

# onready var tabCont = get_node("Control/TextureRect/NinePatchRect/PanelContainer")
# var buttonNum := int()
# var copperAmmount :=int()

# const data = preload("res://Gui/AllModulesGroups.gd").ALL_MODULES_GROUPS

# func _ready():
# 	get_node("Control").set_visible(false)
# 	get_node("ColorRect").set_visible(false)
# 	copperAmmount = 200
# 	var groupId = 0
# 	var buttonId = 0
# 	for button in tabCont.get_node("GridContainer").get_children():
# 		buttonNum += 1
# 		button.connect("mouse_entered", self, "button_enter", [groupId, buttonId])
# 		button.connect("mouse_exited", self, "button_exit", [groupId, buttonId])
# 		button.connect("pressed", self, "button_pressed", [groupId, buttonId])
# 		if data[groupId].elements.size() > buttonId && data[groupId].elements[buttonId].state == true:
# 			if data[groupId].elements[buttonId].get("cost") != null: 
# 				button.setFrame(data[groupId].elements[buttonId].frameId)
# 		else:
# 			button.setFrame(0)
# 			button.set_modulate(Color(0.5,0.5,0.5,1))
# 		buttonId += 1
# 	$Settings.connect("pressed", self, "button_pause")
# 	$BuildMode.connect("pressed", self, "hideShop")
# 	$ExitBuildMode.connect("pressed", self, "showShop")
# #$MiedzCounter/Label.connect("gui_input",self,"copper_counter")

# func button_enter(groupId, buttonId):
# 	if data[groupId].elements.size() >buttonId && data[groupId].elements[buttonId].state == true:
# 		if data[groupId].elements[buttonId].tooltip != null:
# 			$Control/VBoxContainer/ColorRect/Tooltip.text = data[groupId].elements[buttonId].tooltip
# 			$ColorRect/Label.text = str(copperAmmount, "/",data[groupId].elements[buttonId].cost)


# func button_exit(groupId, buttonId):
# 	$Control/VBoxContainer/ColorRect/Tooltip.text = "Tooltip"
# 	$ColorRect/Label.text = str(copperAmmount)

# func button_pressed(groupId, buttonId):
# 	if data[groupId].elements[buttonId].state == true:
# 		if copperAmmount - data[groupId].elements[buttonId].cost >= 0:
# 			var moduleData = data[groupId].elements[buttonId]
# 			emit_signal("module_button_pressed", moduleData)
# 		$Control/VBoxContainer/ColorRect/Tooltip.text = "Insufficient cost"

# #func button_pause():
# #
# #	if beatController.isPaused() == false:
# #		pauseMenu.visible = true
# #		beatController.setPause(true)

# func hideShop():
# 	$Control.visible = false
# 	$ColorRect.visible = false
# 	$ExitBuildMode.visible = false
# 	buildController.switchToNewMachineState()

# func showShop():
# 	$Control.visible = true
# 	$ColorRect.visible = true
# 	$ExitBuildMode.visible = false
# 	buildController.switchToWalkingState()

# func copper_counter(copperAmmount):
# 	$MiedzCounter/Label.set_text(str(copperAmmount))

# #func lock_shop_item(moduleName: String):
# #	var groupCount = 0
# #	for group in data:
# #		var elementCount = 0
# #		for element in group:
# #			if element.get('moduleId') == moduleName:
# #				element.state = false
# #				var button = tabCont.get_child(groupCount).get_node("GridContainer").get_child(elementCount)
# #				button.lock_shop_item()
# #				return
# #			elementCount += 1
# #		groupCount += 1
# #
# #
# #func unlock_shop_item(moduleName: String,groupId, buttonId):
# #	var groupCount = 0
# #	for group in data:
# #		var elementCount = 0
# #		for element in group:
# #			if element.get('moduleId') == moduleName:
# #				element.state = true
# #				var button = tabCont.get_child(groupCount).get_node("GridContainer").get_child(elementCount)
# #				button.unlock_shop_item()
# #				return
# #			elementCount +=1
# #		groupCount +=1
# #
# ##
# #func _unhandled_input(event):
# #	var moduleName = 'drill'
# #	if event.is_action_pressed("lock"):
# #		tabCont.get_child(0).get_node("GridContainer").get_child(0).lock_shop_item()
# #	if event.is_action_pressed("unlock"):
# #		var lockData = data[0].elements[0]
# #		tabCont.get_child(0).get_node("GridContainer").get_child(0).unlock_shop_item(lockData)

