extends Control


const buttonData = [
	{
		'name': "Start",
		'numOfButton': 0,
	},
	{
		'name': "Settings",
		'numOfButton': 1,
	},
	{
		'name': "Quit",
		'numOfButton': 2,
	}
]


func _ready():
	var numOfButton = 0
	for button in get_node("TextureRect/VBoxContainer").get_children():
		button.connect("pressed", self, "main_menu_button_pressed", [numOfButton])
		numOfButton += 1


func main_menu_button_pressed(numOfButton):
	if numOfButton == 1:
		print("starting the game")
		start_game()
	elif numOfButton == 2:
		print("displaying the settings")
		display_settings()
	elif numOfButton == 3:
		print("exiting")
		exit_game()


func start_game():
	pass

func display_settings():
	pass

func exit_game():
	pass
