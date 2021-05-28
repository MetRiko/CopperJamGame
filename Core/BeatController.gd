extends Node

onready var pauseMenu = Game.pauseMenu

signal beat
signal half_beat
signal quarter_beat

signal after_beat
signal after_half_beat
signal after_quarter_beat

var paused = false

func _ready():
	$Timer.connect("timeout", self, "_onBeat")
	$HalfTimer.connect("timeout", self, "_onHalfBeat")
	$QuarterTimer.connect("timeout", self, "_onQuarterBeat")

func _onBeat():
	if paused == false:
		emit_signal("beat")
		emit_signal("after_beat")

func _onHalfBeat():
	if paused == false:
		emit_signal("half_beat")
		emit_signal("after_half_beat")
	
func _onQuarterBeat():
	if paused == false:
		emit_signal("quarter_beat")
		emit_signal("after_quarter_beat")

func pauseGame():
	paused = true
	
func resumeGame():
	paused = false

#func setPause(isPaused):
#	if pauseMenu.isPaused == false:
#		$Timer.paused = true
#		$HalfTimer.paused = true
#		$QuarterTimer.paused = true
#		pauseMenu.isPaused = true
#	elif pauseMenu.isPaused == true:
#		$Timer.paused = false
#		$HalfTimer.paused = false
#		$QuarterTimer.paused = false
#		pauseMenu.isPaused = false
#
#func isPaused():
#	return pauseMenu.isPaused
