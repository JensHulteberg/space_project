extends Node2D

func _ready():
	$Timer.start(1)

func modify_weight():
	get_parent().change_weight_of_tile(position, 100)

func spread():
	var relative_position = get_parent().get_free_relative(self)
	
	if relative_position:
		var danger = Global.get_a_node("res://danger/danger.tscn")
		get_parent().add_child(danger)
		danger.position = relative_position

func _on_Timer_timeout():
	modify_weight()
	spread()
	$Timer.start(1)
