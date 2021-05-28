extends Node


onready var root = get_tree().get_root().get_node("Root")
onready var beatController = root.get_node("BeatController")
onready var menu = root.get_node("MainMenu/Menu")
onready var pauseMenu = root.get_node("PauseMenu/PauseMenu")
onready var musicController = root.get_node("MusicController")

var level = null
var tilemap = null
var gui = null
var nodeEditor = null
var camera = null

func getLevel():
	return level

func _ready():
	reloadLevelReferences(root.get_node("LevelAnchor/Level"))

func reloadLevelReferences(level):
	self.level = level
	camera = level.get_node("Camera")
	tilemap = level.get_node("TileMap")
	gui = level.get_node("CanvasLayer/GUI")
	nodeEditor = level.get_node("CanvasLayer/NodeEditor")
