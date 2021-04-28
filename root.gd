extends Node2D

onready var nav_2d : Navigation2D = $Navigation2D
onready var line_2d : Line2D = $Line2D
onready var character : Sprite = $character
onready var drink : Array = get_tree().get_nodes_in_group("watering_hole")
onready var food : Array = get_tree().get_nodes_in_group("hunger_hole")

func _ready() -> void:
	 character.nav = nav_2d

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
	
	var new_path : = nav_2d.get_simple_path(character.global_position, event.global_position, false)
	line_2d.points = new_path
	#character.path = new_path
