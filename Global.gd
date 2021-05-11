extends Node

func get_a_node(path):
	var scene = load(path).instance()
	return scene
