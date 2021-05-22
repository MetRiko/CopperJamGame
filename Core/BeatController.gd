extends Node

onready var pauseMenu = Game.pauseMenu

signal beat
signal half_beat
signal quarter_beat

var currentBeat = 0
var beatsCount = 10

func _ready():
	$Timer.connect("timeout", self, "_onTimeout")
	$HalfTimer.connect("timeout", self, "_onTimeout2")
	$QuarterTimer.connect("timeout", self, "_onTimeout3")

func _onTimeout():
	currentBeat = (currentBeat + 1) % beatsCount
	emit_signal("beat", currentBeat, beatsCount)

func _onTimeout2():
	emit_signal("half_beat")

func _onTimeout3():
	emit_signal("quarter_beat")

func setPause(isPaused):
	if isPaused == false:
		$Timer.pause = true
		$HalfTimer.pause = true
		$QuarterTimer.pause = true
	elif isPaused == true:
		$Timer.pause = false
		$HalfTimer.pause = false
		$QuarterTimer.pause = false

func isPaused():
	return pauseMenu.isPaused
