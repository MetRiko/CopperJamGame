extends Control

signal module_button_pressed
signal tooltip_hovered

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
				'cost': 10
			},
			{
				'name': "Generator",
				'moduleId' : "generator",
				'frameId':25,
				'tooltip' : "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer volutpat eros a aliquet lobortis. Mauris viverra mauris urna, vitae rhoncus elit fermentum id.",
				'cost': 10
			},
			{
				'name': "Turret", 
				'moduleId' : "turret",
				'frameId':null
			},
			{
				'name': "Tank", 
				'moduleId' : "tank",
				'frameId':null
			},
			{
				'name': "Turret", 
				'moduleId' : "turret",
				'frameId':null
			},
			{
				'name': "Tank", 
				'moduleId' : "tank",
				'frameId':null
			},
			{
				'name': "Turret", 
				'moduleId' : "turret",
				'frameId':null
			},
			{
				'name': "Tank", 
				'moduleId' : "tank",
				'frameId':null
			}
		]
	},
	{
		'groupName': "Group 2",
		'elements': [
			{
				'name': "Tank",
				'moduleId' : "turret",
				'frameId':null
			},
			{
				'name': "Turret",
				'moduleId' : "turret",
				'frameId':null 
			},
			{
				'name': "Drill",
				'moduleId' : "turret",
				'frameId':null 
			}
		]
	},
	{
		'groupName': "Group 3",
		'elements': [
			{
				'name': "Tank",
				'moduleId' : "turret",
				'frameId':null 
			},
			{
				'name': "Turret",
				'moduleId' : "turret",
				'frameId':null
			},
			{
				'name': "Drill",
				'moduleId' : "turret",
				'frameId':null
			}
		]
	}
]



func _ready():
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
			if groupId < 1:
				if data[groupId].elements[buttonId].frameId != null:
					button.setFrame(data[groupId].elements[buttonId].frameId)
					button.get_child(0).set_text(str(data[groupId].elements[buttonId].cost))
			buttonId += 1
		groupId += 1
	$Settings.connect("pressed", self, "button_settings")
	$PauseResume.connect("pressed", self, "button_pause")
#$MiedzCounter/Label.connect("gui_input",self,"copper_counter")



func button_enter(groupId, buttonId):
	if buttonId != null:
		if data[groupId].elements[buttonId].tooltip != null:
			if data[groupId].elements[buttonId].name != null:
				$Control/VBoxContainer/ColorRect/Tooltip.text = data[groupId].elements[buttonId].tooltip
			
		
	

func button_exit(groupId, buttonId):
	$Control/VBoxContainer/ColorRect/Tooltip.text = "Tooltip"

func button_pressed(groupId, buttonId):
	if copperAmmount - data[groupId].elements[buttonId].cost >= 0:
		copperAmmount = copperAmmount - data[groupId].elements[buttonId].cost
		var moduleData = data[groupId].elements[buttonId]
		emit_signal("module_button_pressed", moduleData)
		copper_counter(copperAmmount)
	$Control/VBoxContainer/ColorRect/Tooltip.text = "Insufficient cost"

func button_settings():
	#kod pod ustawienia
	pass

func button_pause():
	#kod pod pauze
	pass

func copper_counter(copperAmmount):
	$MiedzCounter/TextureRect/Label.set_text(str(copperAmmount))

