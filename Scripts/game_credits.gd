extends CanvasLayer

@export var time_to_cut = 5.0

func _process(delta: float) -> void:
	time_to_cut -= delta
	if time_to_cut <= 0:
		time_up()

func time_up():
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
