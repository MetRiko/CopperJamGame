extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#OS.set_window_fullscreen(!OS.window_fullscreen)
	get_node("Timer").connect("timeout", self, "hide_KGHM")
	get_node("Timer").start()

func hide_KGHM():
	get_node(".").visible = false
