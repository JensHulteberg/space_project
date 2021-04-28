extends Sprite

var target = null

func _process(delta):
	if target:
		if target.needs.hunger <= 100.0:
			target.needs.hunger += 10.0


func _on_Area2D2_area_entered(area):
	if area.get_parent().is_in_group("character"):
		target = area.get_parent()
		print("Character in drinking area")


func _on_Area2D2_area_exited(area):
	if area.get_parent() == target:
		target = null
