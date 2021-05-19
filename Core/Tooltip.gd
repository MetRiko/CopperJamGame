extends Control

signal module_button_pressed

onready var tabCont = get_node("Control/TabContainer")
var buttonNum := int()

const data = [
	{
		'groupName': "Group 1",
		'elements': [
			{
				'name': "Drill",
				'moduleId': "drill",
				'frameId':16
			},
			{
				'name': "Generator",
				'moduleId' : "generator",
				'frameId':25
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

#	$MiedzCounter/Label.text = copperAmmount


func _ready():
	var groupId = 0
	for tab in tabCont.get_children():
		var buttonId = 0
		for button in tab.get_node("GridContainer").get_children():
			buttonNum += 1
			button.connect("mouse_entered", self, "button_enter", [groupId, buttonId])
			button.connect("mouse_exited", self, "button_exit", [groupId, buttonId])
			button.connect("pressed", self, "button_pressed", [groupId, buttonId])
			buttonId += 1
		groupId += 1
	$Settings.connect("pressed", self, "button_settings")
	$PauseResume.connect("pressed", self, "button_pause")



func button_enter(groupId, buttonId):
	print(groupId, buttonId)
	if buttonId < data[groupId].elements.size():
		print(data[groupId].elements[buttonId].name)
	else:
		print("unknown element")
	
func button_exit(groupId, buttonId):
	print(groupId, buttonId)
	if buttonId < data[groupId].elements.size():
		print(data[groupId].elements[buttonId].name)
	else:
		print("unknown element")

func button_pressed(groupId, buttonId):
	var moduleData = data[groupId].elements[buttonId]
	emit_signal("module_button_pressed", moduleData)

func button_settings():
	#kod pod ustawienia
	pass

func button_pause():
	#kod pod pauze
	pass
