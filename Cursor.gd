extends Node2D

onready var level = Game.level

onready var buildController = level.getBuildController()

const CURSORS = {
	0: 0,		# Boots
	1: 1,		# Plus
	2: 3,		# Wrench
	3: 9		# Arrow
}

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	position = get_global_mouse_position()
	
	if buildController.onEnemy:
		$Img.frame = 10
	else:
		$Img.frame = CURSORS[buildController.state]
