extends EntityBase

onready var healthController = $HealthController

var isAlive = true

#func _input(event):
#	if event.is_action_pressed('i'):
#		var pointPath = tilemap.get_node('Pathfinding').pathfind(currentCellIdx, tilemap.world_to_map(get_global_mouse_position()))
#		if pointPath.size() >= 2:
#			var point =  pointPath[1] - pointPath[0]
#			move(Vector2(point.x, point.y))
#	if event.is_action_pressed('LMB'):
#		doDamage(1.0)

func _ready():
	healthController.connect("no_health", self, "onNoHealth")
#	Game.tilemap.get_node("FogOfWar").revealTerrain(currentCellIdx, true)

func onNoHealth():
	isAlive = false
	$Tween.interpolate_property($Sprite, 'global_rotation_degrees', global_rotation_degrees, global_rotation_degrees + 720.0, 0.8, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	$Tween.interpolate_property($Sprite, 'global_scale', global_scale, Vector2(0, 0), 0.8, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	queue_free()

func doDamage(value):
	healthController.doDamage(value)
	playAnimationPulse($Sprite)

func moveForward():
	var result = .moveForward()
	
	if result.success == false:
#		Game.tilemap.set_cell(result.targetCellIdx.x, result.targetCellIdx.y, 1)
#		Game.tilemap.get_node("FogOfWar").revealTerrain(result.targetCellIdx)
		playAnimationPulse($Sprite)
