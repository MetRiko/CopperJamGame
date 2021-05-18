extends KinematicBody2D

export (int) var speed = 1300

var velocity = Vector2()

func _on_BPM_Counter_timeout():
	print(velocity)


func _physics_process(delta):
	pass
	#add crashing with walls and other player-made structures

