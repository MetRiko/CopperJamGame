extends Node

signal player_range_changed

onready var level = Game.level

var hashedRangeIdxes = {}
var hashedMoveRangeIdxes = {}

func _ready():
	level.getPlayer().connect("moved", self, "onPlayerMoved")

func _calculateRangeIdxes():
	var playerRange = 7.5
	var idxes = level.getCircleIdxesFromCenter(level.getPlayer().getGlobalIdx(), playerRange)
	hashedRangeIdxes = {}
	hashedMoveRangeIdxes = {}
	for idx in idxes:
		var hashedIdx = hashIdx(idx)
		hashedRangeIdxes[hashedIdx] = idx
		if level.isFreeSpace(idx) and level.isFloorInIdx(idx):
			hashedMoveRangeIdxes[hashedIdx] = idx
	emit_signal("player_range_changed")

func getRangeIdxes():
	return hashedRangeIdxes.values()
	
func getMoveRangeIdxes():
	return hashedMoveRangeIdxes.values()

func onPlayerMoved(a, b):
	_calculateRangeIdxes()

func isIdxInPlayerRange(idx):
	var hashedIdx = hashIdx(idx)
	return hashedRangeIdxes.has(hashedIdx)

func hashIdx(idx : Vector2) -> int:
	var x = idx.x
	var y = idx.y
	var a = -2*x-1 if x < 0 else 2 * x
	var b = -2*y-1 if y < 0 else 2 * y
	return (a + b) * (a + b + 1) * 0.5 + b
