extends TileMap

export (Vector2) var map_size

var path_start_position = Vector2() setget _set_path_start_position
var path_end_position = Vector2() setget _set_path_end_position

var _point_path = []

onready var astar_node = AStar2D.new()
onready var _half_cell_size = cell_size / 2
var obstacles

onready var hunger = get_tree().get_nodes_in_group("hunger")
onready var thirst = get_tree().get_nodes_in_group("thirst")
var to_be_built = []
var fire = []

signal map_recalculated

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
	var click_pos = world_to_map(event.position)
	var clicked_tile_index = get_cellv(click_pos)
	
	
	if clicked_tile_index == -1:
		var build_indicator = Global.get_a_node("res://to_be_built/to_be_built.tscn")
		add_child(build_indicator)
		build_indicator.position = map_to_world(click_pos) + _half_cell_size
		to_be_built.append(build_indicator)
	

func _ready():
	recalculate_walkable_cells()

func recalculate_walkable_cells():
	#astar_node.clear()
	obstacles = get_used_cells_by_id(0)
	#map_size = get_used_rect().end
	map_size = Vector2(20, 20)
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
			if not calculate_point_index(point) in astar_node.get_points():
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

func change_tile_to(index, tile_pos):
	set_cellv(world_to_map(tile_pos), index)
	#astar_node.add_point(calculate_point_index(world_to_map(tile_pos)), world_to_map(tile_pos))
	#emit_signal("map_recalculated")
	recalculate_walkable_cells()

func how_close_is(node):
	return (astar_node.get_closest_position_in_segment(world_to_map(node.position)) - world_to_map(node.position)).length()

func change_weight_of_tile(position, weight):
	astar_node.set_point_weight_scale(calculate_point_index(world_to_map(position)), weight)

func whats_on_this_tile(position):
	var objects = []
	for object in get_children():
		if world_to_map(object.position) == world_to_map(position):
			objects.append(object)
			
	return objects

func check_duplicate(node, tile_position):
	for object in whats_on_this_tile(tile_position):
		if object.get_filename() == node.get_filename():
			return false
	return true

func get_free_relative(node):
	var point = node.position
	var points_relative = PoolVector2Array([
				point + Vector2.RIGHT * cell_size,
				point + Vector2.LEFT * cell_size,
				point + Vector2.DOWN * cell_size,
				point + Vector2.UP * cell_size,
			])
	randomize()
	var index_list = [0, 1, 2, 3]
	index_list.shuffle()
	for x in index_list:
		if world_to_map(points_relative[x]) in obstacles and check_duplicate(node, points_relative[x]):
			return points_relative[x]

func _set_path_start_position(value):
	if not value in obstacles:
		return
	if is_outside_map_boundries(value):
		return
	path_start_position = value

func _set_path_end_position(value):
	if not value in obstacles:
		print("Value: " + String(value) + " is not in walkable tiles. Instead sets a closeby tile: " + String(astar_node.get_closest_position_in_segment(value)))
		path_end_position = astar_node.get_closest_position_in_segment(value)
		return
	if is_outside_map_boundries(value):
		path_end_position = astar_node.get_closest_position_in_segment(value)
		return
	path_end_position = value
