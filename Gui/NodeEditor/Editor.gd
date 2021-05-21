extends ColorRect


onready var level = Game.level
#onready var editor = $Panel/Margin/VBox/Editor
onready var gizmoSprite = $Gizmo/Sprite

var currentGizmoIdx := Vector2()

var currentCameraPos = Vector2()

var selectedInstructionFromToolbar = 0

func selectInstructionFromToolbar(instructionData):
	selectedInstructionFromToolbar = instructionData
	if instructionData != null:
		gizmoSprite.frame = instructionData.frameId
		gizmoSprite.visible = true
	else:
		gizmoSprite.visible = false

func moveCamera(offset : Vector2):
	currentCameraPos += offset

func _process(delta):
	
	var mousePos = get_global_mouse_position() - rect_global_position - currentCameraPos
	var mouseIdx = mousePos / level.getCellSize()
	mouseIdx.x = floor(mouseIdx.x)
	mouseIdx.y = floor(mouseIdx.y)
	if int(mouseIdx.x) % 2 == 0 and int(mouseIdx.y) % 2 == 0:
		currentGizmoIdx = mouseIdx
		var pos = level.tilemap.cell_size * mouseIdx + rect_global_position + currentCameraPos
		gizmoSprite.global_position = pos
		gizmoSprite.self_modulate.a = 1.0
	else:
		var pos = get_global_mouse_position() - level.getHalfCellSize()
		gizmoSprite.self_modulate.a = 0.4
		gizmoSprite.global_position = pos
#		gizmoSprite.visible = false
		
	if Input.is_action_pressed("up"):
		moveCamera(Vector2(0, -4.0))
	if Input.is_action_pressed("down"):
		moveCamera(Vector2(0, 4.0))
	if Input.is_action_pressed("left"):
		moveCamera(Vector2(-4.0, 0))
	if Input.is_action_pressed("right"):
		moveCamera(Vector2(4.0, 0))
	
	update()
	
	
func _draw():
	for x in range(8):
		for y in range(10):
			var pos = Vector2(x * 2, y * 2) * level.getCellSize().x 
			pos.x += fmod(currentCameraPos.x, level.getCellSize().x * 2) - 2 * level.getCellSize().x
			pos.y += fmod(currentCameraPos.y, level.getCellSize().y * 2) - 2 * level.getCellSize().y
			draw_rect(Rect2(pos, level.getCellSize()), Color.red, false, 1)
