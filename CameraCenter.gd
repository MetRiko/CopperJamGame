extends KinematicBody2D

onready var beatController = Game.beatController
onready var pauseMenu = Game.pauseMenu
onready var menu = Game.menu

export var min_speed := 400

export var max_speed := 2400

export (int) var speed = 800

var velocity = Vector2()

func _ready():
	speed = 500.0 * sqrt($CameraNode._zoom_level)

func get_input(delta):
	#if menu.gameStarted == true:
		if beatController.isPaused() == false:
			
			var dir = Vector2()
			
			velocity *= 0.88
			if Input.is_action_pressed("right"):
				dir.x += 1
			if Input.is_action_pressed("left"):
				dir.x -= 1
			if Input.is_action_pressed("down"):
				dir.y += 1
			if Input.is_action_pressed("up"):
				dir.y -= 1
				
			velocity += dir.normalized() * speed * delta * (pow(velocity.length(), 0.5) + 20.0) * 0.5


func _physics_process(delta):
	get_input(delta)
	if beatController.isPaused() == false:
		move_and_slide(velocity)
