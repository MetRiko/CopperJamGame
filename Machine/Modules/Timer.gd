extends Timer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().connect("timeout", self, "hide")


func hide():
	get_parent().visible = true
	get_parent().visible = true
