extends KinematicBody2D

export (int) var speed = 1300

var velocity = Vector2()

func _on_BPM_Counter_timeout():
	velocity = Vector2()
	velocity.x += 1
	velocity = velocity.normalized() * speed
	velocity = move_and_slide(velocity)
	print(velocity)


func _physics_process(delta):
	pass
	#add crashing with walls and other player-made structures

