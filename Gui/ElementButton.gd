extends Button

onready var gui = Game.gui


func _ready():
	pass
	#gui.connect("unlockSignal", self, "unlock_shop_item")
	#gui.connect("lockSignal", self, "lock_shop_item")
	
func lock_shop_item():
	setFrame(0)
	get_child(0).set_text("")
	set_modulate(Color(0.5,0.5,0.5,1))

func unlock_shop_item(lockData):
	setFrame(lockData.frameId)
	get_child(0).set_text(str(lockData.cost))
	modulate = Color(1,1,1,1)

func setFrame(frame):
	$TextureRect.frame = frame
