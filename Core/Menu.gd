extends Control

onready var beatController = Game.beatController
onready var logo = $TextureRect/VBoxContainer/Logo

var gameStarted := false

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

func showMenu():
	show()
	gameStarted = false
	$Tween.interpolate_property($Back, "modulate:a", null, 1.0, 0.6, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	
	$Tween.interpolate_property(logo, "modulate:a", null, 1.0, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()
	yield(get_tree().create_timer(0.4), "timeout")
	
	$Tween.interpolate_property($TextureRect, "modulate:a", null, 1.0, 0.6, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield(get_tree().create_timer(0.4), "timeout")
	

func _ready():
	$TextureRect/VBoxContainer/Start.connect("pressed", self, "onStartGame")
	$TextureRect/VBoxContainer/Quit.connect("pressed", self, "onQuitGame")
	Game.camera.disableCamera()
	level.set_process(false)
	Game.musicController.enableMainTheme()
	Game.musicController.enableChillTheme()
	Game.level.getPlayerInputController().disablePlayerInput()
	Game.gui.hide()

func onStartGame():
	startGame()
	var button = $TextureRect/VBoxContainer/Start
	$Tween.interpolate_property(button, "rect_scale", Vector2(1.0, 1.0), Vector2(1.08, 1.08), 0.15, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Tween.interpolate_property(button, "rect_scale", button.rect_scale, Vector2(0.95, 0.95), 0.7, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	
func onQuitGame():
	var button = $TextureRect/VBoxContainer/Quit
	$Tween.interpolate_property(button, "rect_scale", Vector2(1.0, 1.0), Vector2(1.08, 1.08), 0.15, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Tween.interpolate_property(button, "rect_scale", button.rect_scale, Vector2(0.95, 0.95), 0.7, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	exitGame()

func startGame(force = false):
	Game.beatController.resumeGame()
	Game.musicController.disableMainTheme()
	
	if force == false:
		$Tween.interpolate_property($TextureRect, "modulate:a", 1.0, 0.0, 1.2, Tween.TRANS_SINE, Tween.EASE_OUT)
		$Tween.start()
		yield(get_tree().create_timer(0.4), "timeout")
	#	yield($Tween, "tween_completed")
		
		$Tween.interpolate_property(logo, "modulate:a", 1.0, 0.0, 0.8, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.start()
		yield(get_tree().create_timer(0.4), "timeout")
		$Tween.interpolate_property($Back, "modulate:a", 1.0, 0.0, 1.2, Tween.TRANS_SINE, Tween.EASE_OUT)
		$Tween.start()
		yield($Tween, "tween_all_completed")
	
	Game.camera.enableCamera()
	Game.level.set_process(true)
	Game.level.getPlayerInputController().enablePlayerInput()
	Game.gui.show()
	Game.level.getPlayerInputController().changeStateToNormal()
	gameStarted = true
	hide()

func exitGame():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

