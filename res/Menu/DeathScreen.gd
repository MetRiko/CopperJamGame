extends Control

onready var level = Game.level
onready var menu = Game.menu
onready var pic = Game.level.getPlayerInputController()

func _ready():
	level.connect("player_died",self,"onPlayerDied")
	hide()

func onPlayerDied():
	pic.disablePlayerInput()
	show()

func _unhandled_input(event):
	if event.is_action_pressed("space") and visible == true:
		hide()
		Game.root.resetLevel()
