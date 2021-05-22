extends Control

onready var gui = Game.gui
var gameStarted := false

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
	var numOfButton = -1
	for button in get_node("TextureRect/VBoxContainer").get_children():
		button.connect("pressed", self, "main_menu_button_pressed", [numOfButton])
		numOfButton += 1
		
		if numOfButton == 0:
			get_node("TextureRect/VBoxContainer/Start/Label").text = "Start"
		elif numOfButton == 2:
			get_node("TextureRect/VBoxContainer/Quit/Label").text = "Quit"


func main_menu_button_pressed(numOfButton):
	if numOfButton == 0:
		print("starting the game")
		start_game()
	elif numOfButton == 1:
		print("no button here")
		#restart()
	elif numOfButton == 2:
		print("exiting")
		exit_game()


func start_game():
	gameStarted = true
	get_node(".").visible = false
	gui.visible = true

func restart():
	#get_node("TextureRect").visible = false
	pass

func exit_game():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

func _unhandled_input(event):
	if get_node("TextureRect").visible == false and event.is_action_pressed("pause"):
		get_node("TextureRect").visible == true
