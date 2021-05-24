extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#OS.set_window_fullscreen(!OS.window_fullscreen)
#	var timer = get_node("Timer")
#	timer.connect("timeout", self, "hide_KGHM")
#	timer.start()
#	yield(timer, "timeout")
#	queue_free()
	yield(get_tree().create_timer(4.7), "timeout")
	$Tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	queue_free()
