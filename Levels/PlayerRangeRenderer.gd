extends Node2D

onready var level = Game.level
onready var pic = level.getPlayerInputController()

var rangeIdxes = []

func _ready():
	level.getPlayer().connect("moved", self, "onPlayerMoved")
#	_calculateRangeIdxes()
#	onPlayerMoved(null, null)

func _calculateRangeIdxes():
	var playerRange = 7.1
	var idxes = level.getCircleIdxesFromCenter(level.getPlayer().getGlobalIdx(), playerRange)
	var floorIdxes = []
	for idx in idxes:
		if level.isFreeSpace(idx) and level.isFloorInIdx(idx):
			floorIdxes.append(idx)
	rangeIdxes = floorIdxes 

func onPlayerMoved(a, b):
	_calculateRangeIdxes()
	update()
	
func _draw():
	for idx in rangeIdxes:
		var pos = level.getPosFromCellIdx(idx)
		var size = level.getCellSize()
		draw_rect(Rect2(pos, size), Color.green, false, 1.0, true) 
