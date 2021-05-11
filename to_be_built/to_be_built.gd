extends Node2D

var count = 3

func in_interaction_area(object):
	var overlapping_areas = $Area2D.get_overlapping_areas()
	for area in overlapping_areas:
		if area.get_parent() == object:
			return true
	return false

func act(target):
	count -= 1
	if count <= 0:
		var map_pos = get_parent().world_to_map(position)
		get_parent().change_tile_to(0, map_pos)
		die()

func die():
	get_parent().to_be_built.erase(self)
	queue_free()
