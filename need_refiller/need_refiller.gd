extends Node2D

export(String, "hunger", "thirst", "NONE") var need

var target = null

func _ready():
	add_to_group(need)

func in_interaction_area(object):
	var overlapping_areas = $Area2D.get_overlapping_areas()
	for area in overlapping_areas:
		if area.get_parent() == object:
			return true
	return false

func act(target):
	print("Filling up: " + String(need))
	target.needs[need] += 100

