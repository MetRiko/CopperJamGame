extends Node2D

signal no_health

onready var entity = get_parent()

var hp = 4.0
var maxHp = 4.0

onready var maxWidth = $Hp.rect_size.x

#func _input(event):
#	if event.is_action_pressed("LMB"):
#		doDamage(1)

var shouldBeDead = 0

func _ready():
	modulate.a = 0
	
func addHp(value):
	setHp(hp + value)
	
func setHp(value):
	if value <= 0.0 and shouldBeDead == 0:
		shouldBeDead = 1
	hp = clamp(value, 0.0, maxHp)
	_visualUpdate()
	
func doDamage(value):
	addHp(-value)
	$Tween.interpolate_property(self, 'modulate:a', modulate.a, 0.8, 0.8, Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
	$Tween.interpolate_property(self, 'modulate:a', 0.8, 0.0, 0.8, Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
	$Tween.interpolate_property(self, 'global_scale', global_scale, Vector2(1.2, 1.2), 0.2, Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
	$Tween.interpolate_property(self, 'global_scale', Vector2(1.2, 1.2), Vector2(1.0, 1.0), 0.2, Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
	
func _visualUpdateSize():
	var startSize = $Hp.rect_size.x
	var endSize = hp / maxHp * maxWidth
	
	$Tween.interpolate_property($Hp, 'rect_size:x', startSize, endSize, 0.2, Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	if shouldBeDead == 1:
		shouldBeDead = 2
		emit_signal("no_health")
	
func _visualUpdate():
#	$Hp.rect_size.x = hp / maxHp * maxWidth
	_visualUpdateSize()
