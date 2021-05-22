extends Control

var value = 0
#var initPos := Vector2()

func _ready():
	while true:
		$Tween.interpolate_method(self, "onTween", 0.0, 1.0, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
		$Tween.start()
		yield($Tween, "tween_completed")
		$Tween.interpolate_method(self, "onTween", 1.0, 0.0, 0.2, Tween.TRANS_SINE, Tween.EASE_IN)
		$Tween.start()
		yield($Tween, "tween_completed")
		
func onTween(value):
	self.value = value
	update()

func _draw():
	var radius = (value * 0.2 + 1.1) * 32.0
	var size = Vector2(radius, radius)
	draw_rect(Rect2(rect_position - size * 0.5, size), Color(1.0, 0.0, 0.0, 0.7), false, (value * 2.0 + 0.2), true)
#	draw_circle(rect_global_position - get_parent().rect_global_position, radius, Color.red)
