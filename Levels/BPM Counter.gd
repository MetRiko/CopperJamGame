extends Timer

export var BPM = 60


func _ready():
	wait_time =  60 / BPM
	start()
