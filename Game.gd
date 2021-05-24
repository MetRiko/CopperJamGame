extends Node


onready var root = get_tree().get_root().get_node("Root")
onready var tilemap = root.get_node("Level/TileMap")
#onready var tilemap2 = root.get_node("NoNoiseLevel/TileMap")
onready var beatController = root.get_node("BeatController")
onready var level = root.get_node("Level")
onready var gui = root.get_node("Level/CanvasLayer/GUI")
onready var menu = root.get_node("MainMenu/Menu")
onready var pauseMenu = root.get_node("PauseMenu/PauseMenu")
onready var nodeEditor = root.get_node("Level/CanvasLayer/NodeEditor")
onready var musicController = root.get_node("MusicController")

