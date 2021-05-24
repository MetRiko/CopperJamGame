extends Control

onready var beatController = Game.beatController
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
	start_game()
	$TextureRect/VBoxContainer/Start.connect("pressed", self, "onStartGame")
	$TextureRect/VBoxContainer/Quit.connect("pressed", self, "onQuitGame")
	$WindowDialog.queue_free()
	$TextureRect.queue_free()
	set_process_input(false)

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

func onStartGame():
	start_game()
	
func onQuitGame():
	exit_game()

func start_game():
	gameStarted = true
	$WindowDialog.visible = false
	$TextureRect.visible = false
	visible = true
	gui.visible = true
	#$KGHM.visible = false
#	beatController.setPause(false)

func restart():
	#get_node("TextureRect").visible = false
	pass

func exit_game():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

#func _unhandled_input(event):
#	if get_node("TextureRect").visible == false and event.is_action_pressed("pause"):
#		get_node("TextureRect").visible == true
