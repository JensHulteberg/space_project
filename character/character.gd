extends Sprite

var path = []
var goal = null
onready var map = $"../astar_map"

var needs = {
	"hunger": 100,
	"thirst": 100
	}

signal done_moving

func _ready():
	$"../astar_map".connect("map_recalculated", self, "_on_map_recalculated")
	_on_map_recalculated()

func initiate_movement():
	$Timer.start(0.5)

func _move_to_next_node():
	if path.size() == 0:
		if !_try_to_interact():
			_idle_for_tick()
		goal = null
		return
		
	position = Vector2(path[0])
	path.remove(0)
	initiate_movement()

func _decrease_needs():
	needs.hunger -= 0.1
	needs.thirst -= 0.2
	
	for key in needs:
		if needs[key] < 0:
			needs[key] = 0

func _sort_out_priorities():
	if needs.hunger <= 20:
		set_path_to(map.hunger[0])
		print("Going to eat")
	elif needs.thirst <= 20:
		set_path_to(map.thirst[0])
		print("Going to drink")
	elif map.to_be_built:
		build()
		print("Going to build")
	elif map.fire:
		firefight()

func build():
	for i in map.to_be_built.size():
			if map.how_close_is(map.to_be_built[i]) <= 1:
				set_path_to(map.to_be_built[i])
				return

func firefight():
	for i in map.fire.size():
			if map.how_close_is(map.fire[i]) <= 1:
				set_path_to(map.fire[i])
				return

func set_path_to(new_goal):
	if goal:
		return
		
	goal = new_goal
	if typeof(goal) == 5:
		path = map.get_astar_path(position, goal)
	else:
		path = map.get_astar_path(position, goal.position)
	$"../Line2D".points = path


func _try_to_interact():
	if typeof(goal) == 5:
		return false
	
	if !is_instance_valid(goal):
		return false
	
	if goal:
		if goal.in_interaction_area(self):
			if goal.has_method("act"):
				goal.act(self)
		return
	
	return false

func _on_map_recalculated():
	initiate_movement()

func _idle_for_tick():
	var point = position
	var points_relative = PoolVector2Array([
				point + Vector2.RIGHT * map.cell_size,
				point + Vector2.LEFT * map.cell_size,
				point + Vector2.DOWN * map.cell_size,
				point + Vector2.UP * map.cell_size,
			])
	randomize()
	var index_list = [0, 1, 2, 3]
	index_list.shuffle()
	for x in index_list:
		if map.world_to_map(points_relative[x]) in map.obstacles:
			set_path_to(points_relative[x])
			return

func _on_Timer_timeout():
	_decrease_needs()
	_sort_out_priorities()
	_move_to_next_node()
