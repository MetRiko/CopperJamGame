extends KinematicBody2D

export var generatorRange = 500.0



func _draw():
	draw_circle(get_position(), generatorRange, Color( 0.5, 1, 0.83, 0.2))


