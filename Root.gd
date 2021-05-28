extends Node2D

onready var levelTscn = preload("res://Levels/Level.tscn")

func _ready():
	VisualServer.set_default_clear_color(Color('#252834'))
	
#	$MusicController.setup()
	$MainMenu/Menu.startGame(true)
	
#	$AudioStreamPlayer.play()

func _resetLevel():
	var newLevel = levelTscn.instance()
	var level = $LevelAnchor.get_child(0)
	level.queue_free()
	Game.reloadLevelReferences(newLevel)
	$LevelAnchor.add_child(newLevel)

func _input(event):
	if event.is_action_pressed("num1"):
		_resetLevel()
