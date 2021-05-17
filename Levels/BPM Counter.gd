extends Timer

export var BPM = 60


func _ready():
	wait_time = BPM / 60
