extends Control

var beginPos := Vector2()
var endPos := Vector2()
var color := Color.white

func setPoints(beginPos, endPos, color := Color.white):
	self.beginPos = beginPos - rect_global_position
	self.endPos = endPos - rect_global_position
	self.color = color
	$Sprite.global_position = endPos
	var angle = (endPos - beginPos).angle()
	$Sprite.global_rotation = angle
	$Sprite.modulate = color

func _process(delta):
	update()
	
func _draw():
	draw_line(beginPos, endPos, color, 2.0, true)
