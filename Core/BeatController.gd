extends Node

signal beat

var currentBeat = 0
var beatsCount = 10

func _ready():
	$Timer.connect("timeout", self, "_onTimeout")

func _onTimeout():
	currentBeat = (currentBeat + 1) % beatsCount
	emit_signal("beat", currentBeat, beatsCount)
