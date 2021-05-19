extends Control

onready var tabCont = get_node("Control/TabContainer")
var buttonNum := int()

const data = [
	{
		'groupName': "Group 1",
		'elements': [
			{
				'name': "Tank" 
			},
			{
				'name': "Turret" 
			},
			{
				'name': "Drill" 
			}
		]
	},
	{
		'groupName': "Group 2",
		'elements': [
			{
				'name': "Tank" 
			},
			{
				'name': "Turret" 
			},
			{
				'name': "Drill" 
			}
		]
	},
	{
		'groupName': "Group 3",
		'elements': [
			{
				'name': "Tank" 
			},
			{
				'name': "Turret" 
			},
			{
				'name': "Drill" 
			}
		]
	}
]

func _ready():
	var groupId = 0
	for tab in tabCont.get_children():
		var buttonId = 0
		for button in tab.get_node("GridContainer").get_children():
			buttonNum += 1
			button.connect("mouse_entered", self, "button_enter", [groupId, buttonId])
			button.connect("mouse_exited", self, "button_exit", [groupId, buttonId])
			buttonId += 1
		groupId += 1

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



