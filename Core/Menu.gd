extends Control

onready var beatController = Game.beatController
onready var gui = Game.gui
var gameStarted := false

onready var camera = Game.root.get_node("Camera")
onready var level = Game.level

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
	$TextureRect/VBoxContainer/Start.connect("pressed", self, "onStartGame")
	$TextureRect/VBoxContainer/Quit.connect("pressed", self, "onQuitGame")
	camera.disableCamera()
	level.set_process(false)
	Game.musicController.enableMainTheme()
	Game.musicController.enableChillTheme()

func onStartGame():
	startGame()
	
func onQuitGame():
	exitGame()

func startGame():
	Game.musicController.disableMainTheme()
	camera.enableCamera()
	level.set_process(true)
	gameStarted = true
	gui.show()
	hide()
	get_parent().get_parent().set_process(false)

func exitGame():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

