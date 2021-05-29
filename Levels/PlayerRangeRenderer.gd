extends Node2D

onready var level = Game.level
onready var playerRangeCtrl = level.getPlayerRangeController()

func _ready():
	playerRangeCtrl.connect("player_range_changed", self, "onPlayerRangeChanged")
#	_calculateRangeIdxes()
#	onPlayerMoved(null, null)

func onPlayerRangeChanged():
	update()
	
func _draw():
	for idx in playerRangeCtrl.getMoveRangeIdxes():
		var pos = level.getPosFromCellIdx(idx)
		var size = level.getCellSize()
		draw_rect(Rect2(pos, size), Color.green, false, 1.0, true) 
