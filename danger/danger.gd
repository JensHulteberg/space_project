extends Node2D

func _ready():
	$Timer.start(0.1)

func modify_weight():
	get_parent().change_weight_of_tile(position, 100)


func _on_Timer_timeout():
	modify_weight()
