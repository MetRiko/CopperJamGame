extends Node

onready var main = $MainTheme
onready var chill = $ChillTheme

const ZERO_VOLUME = -80.0
const NORMAL_VOLUME = -20.0

func setup():
	main.play()
	chill.play()
	main.volume_db = ZERO_VOLUME
	chill.volume_db = ZERO_VOLUME


func enableMainTheme():
	$Tween.interpolate_property(main, "volume_db", main.volume_db, NORMAL_VOLUME, 3.0, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()

func disableMainTheme():
	$Tween.interpolate_property(main, "volume_db", main.volume_db, ZERO_VOLUME, 3.0, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()

func enableChillTheme():
	$Tween.interpolate_property(chill, "volume_db", chill.volume_db, NORMAL_VOLUME, 3.0, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()

func disableChillTheme():
	$Tween.interpolate_property(chill, "volume_db", chill.volume_db, ZERO_VOLUME, 3.0, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()

