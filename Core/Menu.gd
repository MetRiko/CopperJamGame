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

func startGame():
	Game.musicController.disableMainTheme()
	
	$Tween.interpolate_property($TextureRect, "modulate:a", 1.0, 0.0, 1.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield(get_tree().create_timer(0.4), "timeout")
#	yield($Tween, "tween_completed")
	
	$Tween.interpolate_property($Logo, "modulate:a", 1.0, 0.0, 0.8, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()
	yield(get_tree().create_timer(0.4), "timeout")
	$Tween.interpolate_property($Back, "modulate:a", 1.0, 0.0, 1.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	
	camera.enableCamera()
	level.set_process(true)
	gameStarted = true
	get_parent().get_parent().set_process(false)
	gui.show()
	hide()

func exitGame():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

