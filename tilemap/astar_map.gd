extends TileMap

export (Vector2) var map_size

var path_start_position = Vector2() setget _set_path_start_position
var path_end_position = Vector2() setget _set_path_end_position

var _point_path = []

onready var astar_node = AStar2D.new()
onready var _half_cell_size = cell_size / 2
var obstacles

signal map_recalculated

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
	var click_pos = world_to_map(event.position)
	var clicked_tile_index = get_cellv(click_pos)
	
	print(click_pos)
	
	if clicked_tile_index == 0:
		set_cellv(click_pos, -1)
	elif clicked_tile_index == -1:
		set_cellv(click_pos, 0)
	
	recalculate_walkable_cells()
	

func _ready():
	recalculate_walkable_cells()

func recalculate_walkable_cells():
	astar_node.clear()
	obstacles = get_used_cells_by_id(0)
	map_size = get_used_rect().end
	var walkable_cells_list = astar_add_walkable_cells(obstacles)
	astar_connect_walkable_cells(walkable_cells_list)
	emit_signal("map_recalculated")

func astar_add_walkable_cells(obstacle_list = []):
	var points_array = []
	for y in range(map_size.y):
		for x in range(map_size.x):
			var point = Vector2(x, y)
			if not point in obstacle_list:
				continue
			points_array.append(point)
			var point_index = calculate_point_index(point)
			astar_node.add_point(point_index, point)
	return points_array

func astar_connect_walkable_cells(point_array):
	for point in point_array:
		var point_index = calculate_point_index(point)
		var points_relative = PoolVector2Array([
			point + Vector2.RIGHT,
			point + Vector2.LEFT,
			point + Vector2.DOWN,
			point + Vector2.UP,
		])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)
			
			if is_outside_map_boundries(point_relative):
				continue
			if not astar_node.has_point(point_relative_index):
				continue
			astar_node.connect_points(point_index, point_relative_index, false)

func get_astar_path(world_start, world_end):
	self.path_start_position = world_to_map(world_start)
	self.path_end_position = world_to_map(world_end)
	_recalculate_path()
	var path_world = []
	for point in _point_path:
		var point_world = map_to_world(point) + _half_cell_size
		path_world.append(point_world)
	return path_world

func calculate_point_index(point):
	return point.x + map_size.x * point.y

func _recalculate_path():
	var start_point_index = calculate_point_index(self.path_start_position)
	var end_point_index = calculate_point_index(self.path_end_position)
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)
	

func is_outside_map_boundries(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y

func _set_path_start_position(value):
	if not value in obstacles:
		return
	if is_outside_map_boundries(value):
		return
	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()

func _set_path_end_position(value):
	if not value in obstacles:
		return
	if is_outside_map_boundries(value):
		return
	path_end_position = value
	if path_start_position != value:
		_recalculate_path()