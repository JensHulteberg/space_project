extends Node2D

export(String, "hunger", "thirst", "NONE") var need

var target = null

func _ready():
	add_to_group(need)

func act(target):
	print("Filling up: " + String(need))
	target.needs[need] += 100

