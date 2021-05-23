extends Node2D

onready var level = Game.level

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	position = get_global_mouse_position()
	if level.get_node("Controllers/BuildController").state == 0:
		get_child(0).visible = true
		get_child(1).visible = false
		get_child(2).visible = false
	elif level.get_node("Controllers/BuildController").state == 1:
		get_child(1).visible = true
		get_child(0).visible = false
		get_child(2).visible = false
	elif level.get_node("Controllers/BuildController").state == 2:
		get_child(2).visible = true
		get_child(0).visible = false
		get_child(1).visible = false
