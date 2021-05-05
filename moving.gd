extends Sprite

var path = []
var goal = null

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
		emit_signal("done_moving")
		goal = null
		return
	
	position = Vector2(path[0])
	path.remove(0)
	initiate_movement()

func _decrease_needs():
	print("Decreasing needs")
	needs.hunger -= 5
	needs.thirst -= 8
	
	for key in needs:
		if needs[key] < 0:
			needs[key] = 0

func set_path_to(goal):
	if !goal:
		return
	path = $"../astar_map".get_astar_path(position, goal.position)

func _on_map_recalculated():
	set_path_to(goal)
	initiate_movement()

func _on_Timer_timeout():
	_decrease_needs()
	_move_to_next_node()
