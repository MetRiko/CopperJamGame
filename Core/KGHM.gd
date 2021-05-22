extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#OS.set_window_fullscreen(!OS.window_fullscreen)
	var timer = get_node("Timer")
	timer.connect("timeout", self, "hide_KGHM")
	timer.start()
	yield(timer, "timeout")
	queue_free()
