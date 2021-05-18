extends Node2D

export var drawLines := bool(false)

onready var tilemap = Game.tilemap2

const BASE_LINE_WIDTH = 1.0
const DRAW_COLOR = Color('#fff')

var astar = AStar.new()
export(Vector2) var map_size = Vector2(16,16)

var path_start_position = Vector2() setget _set_path_start_position
var path_end_position = Vector2() setget _set_path_end_position

var obstacles
var _point_path = []
var _half_cell_size = Vector2()

func pathfind(start : Vector2, end : Vector2):
	self.path_start_position = start
	self.path_end_position = end
	return _point_path

#func _input(event):
#	if event.is_action_pressed('LMB') and Input.is_key_pressed(KEY_SHIFT):
#		self.path_start_position = tilemap.world_to_map(get_global_mouse_position())
#	elif event.is_action_pressed('LMB'):
#		self.path_end_position = tilemap.world_to_map(get_global_mouse_position())

func _ready():
	_half_cell_size = tilemap.cell_size / 2
	obstacles = tilemap.get_used_cells_by_id(0)
	var walkable_cells_list = astar_add_walkable_cells(obstacles)
	astar_connect_walkable_cells(walkable_cells_list)

func astar_add_walkable_cells(obstacles = []):
	var points_array = []
	for y in range(map_size.y):
		for x in range(map_size.x):
			var point = Vector2(x,y)
			if point in obstacles:
				continue
				
			points_array.append(point)
			var point_index = calculate_point_index(point)
			astar.add_point(point_index, Vector3(point.x,point.y,0.0))
	return points_array

func astar_connect_walkable_cells(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		var points_relative = PoolVector2Array([
			Vector2(point.x + 1,point.y),
			Vector2(point.x - 1, point.y),
			Vector2(point.x, point.y +1),
			Vector2(point.x,point.y -1)])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)
			if is_outside_map_bounds(point_relative):
				continue
			if not astar.has_point(point_relative_index):
				continue
			astar.connect_points(point_index, point_relative_index, true)

func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y

func calculate_point_index(point):
	return point.x + map_size.x * point.y

func _recalculate_path():
	if drawLines == true:
		clear_previous_path_drawing()
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	_point_path = astar.get_point_path(start_point_index,end_point_index)
	if drawLines == true:
		update()

func clear_previous_path_drawing():
	if not _point_path:
		return
	var point_start = _point_path[0]
	var point_end = _point_path[len(_point_path) - 1]

func _draw():
	if drawLines == true:
		if not _point_path:
			return
		var point_start = _point_path[0]
		var point_end = _point_path[len(_point_path) - 1]

		var last_point = tilemap.map_to_world(Vector2(point_start.x, point_start.y)) + _half_cell_size
		for index in range(1, len(_point_path)):
			var current_point = tilemap.map_to_world(Vector2(_point_path[index].x, _point_path[index].y)) + _half_cell_size
			draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
			draw_circle(current_point, BASE_LINE_WIDTH * 2.0, DRAW_COLOR)
			last_point = current_point

func _set_path_start_position(value):
	if value in obstacles:
		return
	if is_outside_map_bounds(value):
		return
	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()

func _set_path_end_position(value):
	if value in obstacles:
		return
	if is_outside_map_bounds(value):
		return
	path_end_position = value
	if path_start_position != value:
		_recalculate_path()
