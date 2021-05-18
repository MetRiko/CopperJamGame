extends Node


onready var root = get_tree().get_root().get_node("Root")
onready var tilemap = root.get_node("NoiseLevel/TileMap")
onready var tilemap2 = root.get_node("NoNoiseLevel/TileMap")

