extends Sprite

var speed : = 400.0
var path : = PoolVector2Array() setget set_path
var nav : Navigation2D = null setget set_nav


var needs : = {
	"thirst": 100.0,
	"hunger": 100.0,
	}

func _ready() -> void:
	pass

func _process(delta : float) -> void:
	path = calculate_priorities()
	
	if path:
		var move_distance : = speed * delta
		move_along_path(move_distance)
	
	modify_needs()
	print(needs)

func move_along_path(distance : float) -> void:
	var starting_point : = position
	for i in range(path.size()):
		var distance_to_next : = starting_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			position = starting_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif distance < 0.0:
			position = path[0]
			set_process(false)
			break
		distance -= distance_to_next
		starting_point = path[0]
		path.remove(0)

func set_nav(value : Navigation2D) -> void:
	nav = value

func set_path(value : PoolVector2Array) -> void:
	path = value
	if value.size() == 0:
		return

func modify_needs() -> void:
	needs.hunger -= 0.5
	needs.thirst -= 0.5

func calculate_priorities() -> PoolVector2Array:
	if needs.thirst < 20:
		return nav.get_simple_path(global_position, get_parent().drink[0].global_position, false)
	elif needs.hunger < 20:
		return nav.get_simple_path(global_position, get_parent().food[0].global_position, false)
	else:
		return PoolVector2Array()
