extends Node

onready var level = get_parent().get_parent()
onready var tilemap = get_parent()
onready var pic = level.getPlayerInputController()

func _ready():
	pic.connect("state_changed", self, "onStateChanged")

func modulate():
	$Tween.interpolate_property(tilemap, "modulate:a", null, 0.5, 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()

func unmodulate():
	$Tween.interpolate_property(tilemap, "modulate:a", null, 1.0, 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()

func onStateChanged(state):

	if state == pic.NORMAL_STATE:
		unmodulate()
	if state == pic.BUILDING_STATE:
		modulate()