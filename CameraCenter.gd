extends KinematicBody2D

export var min_speed := 400

export var max_speed := 2400

export (int) var speed = 800

var velocity = Vector2()

func get_input(delta):
	
	var dir = Vector2()
	
	velocity *= 0.86
	if Input.is_action_pressed("right"):
		dir.x += 1
	if Input.is_action_pressed("left"):
		dir.x -= 1
	if Input.is_action_pressed("down"):
		dir.y += 1
	if Input.is_action_pressed("up"):
		dir.y -= 1
		
	velocity += dir.normalized() * speed * delta * 20.0

func _physics_process(delta):
	get_input(delta)
	move_and_slide(velocity)
