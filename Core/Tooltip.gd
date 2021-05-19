extends Control

onready var tabCont = get_node("Control/TabContainer")
var buttonNum := int()


func _ready():
	for tab in tabCont.get_children():
		for button in get_node("GridContainer").get_children():
			buttonNum += 1
			button.connect("mouse_entered", self, "button_enter", [buttonNum])
			button.connect("mouse_exited", self, "button_exit")

func button_enter(buttonNum):
	match buttonNum:
		1:
	print("button1")
		2:
	print("button2")
		3:
	



