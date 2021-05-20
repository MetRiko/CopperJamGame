extends Control

signal module_button_pressed
#signal tooltip_hovered

onready var tilemap = Game.tilemap
onready var level = Game.level
onready var pauseMenu = Game.pauseMenu
onready var tabCont = get_node("Control/TabContainer")
var buttonNum := int()
var copperAmmount :=int()

const data = [
	{
		'groupName': "Group 1",
		'elements': [
			{
				'name': "Drill",
				'moduleId': "drill",
				'frameId':16,
				'tooltip': "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer volutpat eros a aliquet lobortis. Mauris viverra mauris urna, vitae rhoncus elit fermentum id.",
				'cost': 10,
				'state':true
			},
			{
				'name': "Dpad",
				'moduleId' : "dpad_module",
				'frameId':25,
				'tooltip' : "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer volutpat eros a aliquet lobortis. Mauris viverra mauris urna, vitae rhoncus elit fermentum id.",
				'cost': 10,
				'state':true
			},
			{
				'name': "Turret", 
				'moduleId' : "turret",
				'frameId':null,
				'state':false
			},
			{
				'name': "Tank", 
				'moduleId' : "tank",
				'frameId':null,
				'state':false
			},
			{
				'name': "Turret", 
				'moduleId' : "turret",
				'frameId':null,
				'state':false
			},
			{
				'name': "Tank", 
				'moduleId' : "tank",
				'frameId':null,
				'state':false
			},
			{
				'name': "Turret", 
				'moduleId' : "turret",
				'frameId':null,
				'state':false
			},
			{
				'name': "Tank", 
				'moduleId' : "tank",
				'frameId':null,
				'state':false
			}
		]
	},
	{
		'groupName': "Group 2",
		'elements': [
			{
				'name': "Tank",
				'moduleId' : "turret",
				'frameId':null,
				'state':false
			},
			{
				'name': "Turret",
				'moduleId' : "turret",
				'frameId':null,
				'state':false
			},
			{
				'name': "Drill",
				'moduleId' : "turret",
				'frameId':null,
				'state':false
			}
		]
	},
	{
		'groupName': "Group 3",
		'elements': [
			{
				'name': "Tank",
				'moduleId' : "turret",
				'frameId':null,
				'state':false
			},
			{
				'name': "Turret",
				'moduleId' : "turret",
				'frameId':null,
				'state':false
			},
			{
				'name': "Drill",
				'moduleId' : "turret",
				'frameId':null,
				'state':false
			}
		]
	}
]



func _ready():
	get_node("Control").set_visible(false)
	copperAmmount = 200
	$MiedzCounter/TextureRect/Label.set_text(str(copperAmmount))
	var groupId = 0
	for tab in tabCont.get_children():
		var buttonId = 0
		for button in tab.get_node("GridContainer").get_children():
			buttonNum += 1
			button.connect("mouse_entered", self, "button_enter", [groupId, buttonId])
			button.connect("mouse_exited", self, "button_exit", [groupId, buttonId])
			button.connect("pressed", self, "button_pressed", [groupId, buttonId])
			if data[groupId].elements.size() > buttonId && data[groupId].elements[buttonId].state == true:
				if data[groupId].elements[buttonId].get("cost") != null: 
					button.setFrame(data[groupId].elements[buttonId].frameId)
					button.get_child(0).set_text(str(data[groupId].elements[buttonId].cost))
			else:
				button.setFrame(0)
				button.get_child(0).set_text("")
				button.set_modulate(Color(0.5,0.5,0.5,1))
			buttonId += 1
		groupId += 1
	$Settings.connect("pressed", self, "button_pause")
	$BuildMode.connect("pressed", self, "build_mode")
	$ExitBuildMode.connect("pressed", self, "exit_build_mode")
#$MiedzCounter/Label.connect("gui_input",self,"copper_counter")

func button_enter(groupId, buttonId):
	if data[groupId].elements.size() >buttonId && data[groupId].elements[buttonId].state == true:
		if data[groupId].elements[buttonId].tooltip != null:
			$Control/VBoxContainer/ColorRect/Tooltip.text = data[groupId].elements[buttonId].tooltip


func button_exit(groupId, buttonId):
	$Control/VBoxContainer/ColorRect/Tooltip.text = "Tooltip"

func button_pressed(groupId, buttonId):
	if data[groupId].elements[buttonId].state == true:
		if copperAmmount - data[groupId].elements[buttonId].cost >= 0:
			copperAmmount = copperAmmount - data[groupId].elements[buttonId].cost
			var moduleData = data[groupId].elements[buttonId]
			emit_signal("module_button_pressed", moduleData)
			copper_counter(copperAmmount)
		$Control/VBoxContainer/ColorRect/Tooltip.text = "Insufficient cost"

func button_pause():
	if pauseMenu.isPaused == false:
		pauseMenu.visible = true
		pauseMenu.isPaused = true

func build_mode():
	level.get_node("Controllers/BuildController").hide_gui()
	level.get_node("Controllers/BuildController").state = 1

func exit_build_mode():
	level.get_node("Controllers/BuildController").hide_gui()
	level.get_node("Controllers/BuildController").state = 0

func copper_counter(copperAmmount):
	$MiedzCounter/TextureRect/Label.set_text(str(copperAmmount))


func lock_shop_item(moduleName: String):
	var groupCount = 0
	for group in data:
		var elementCount = 0
		for element in group:
			if element.get('moduleId') == moduleName:
				element.state = false
				var button = tabCont.get_child(groupCount).get_node("GridContainer").get_child(elementCount)
				button.lock_shop_item()
				return
			elementCount += 1
		groupCount += 1


func unlock_shop_item(moduleName: String,groupId, buttonId):
	var groupCount = 0
	for group in data:
		var elementCount = 0
		for element in group:
			if element.get('moduleId') == moduleName:
				element.state = true
				var button = tabCont.get_child(groupCount).get_node("GridContainer").get_child(elementCount)
				button.unlock_shop_item()
				return
			elementCount +=1
		groupCount +=1


func _unhandled_input(event):
	var moduleName = 'drill'
	if event.is_action_pressed("lock"):
		tabCont.get_child(0).get_node("GridContainer").get_child(0).lock_shop_item()
	if event.is_action_pressed("unlock"):
		var lockData = data[0].elements[0]
		tabCont.get_child(0).get_node("GridContainer").get_child(0).unlock_shop_item(lockData)

