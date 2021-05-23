extends Node2D

onready var level = Game.level

onready var buildController = level.get_node("Controllers/BuildController")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	position = get_global_mouse_position()
	
	if buildController.onEnemy == true and buildController.state != 2:
		get_child(0).visible = false
		get_child(1).visible = false
		get_child(2).visible = false
		get_child(3).visible = true
	elif buildController.state == 0:
		get_child(0).visible = true
		get_child(1).visible = false
		get_child(2).visible = false
		get_child(3).visible = false
	elif buildController.state == 1:
		get_child(1).visible = true
		get_child(0).visible = false
		get_child(2).visible = false
		get_child(3).visible = false
	elif buildController.state == 2:
		get_child(2).visible = true
		get_child(0).visible = false
		get_child(1).visible = false
		get_child(3).visible = false
