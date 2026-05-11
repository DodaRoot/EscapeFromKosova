extends Control

@onready var guns_container: VBoxContainer = $DefaultMenu/ScrollContainer/GunsContainer

func _ready() -> void:
	MenuMusic.play_music()
	for guns in guns_container.get_children():
		if Global.guns.has(str(guns.name)):
			var item_container = guns.get_child(0)
			var texture = item_container.get_child(0)
			var text = item_container.get_child(1)
			var price = text.get_child(2)
			texture.modulate = Color8(255, 255, 255, 255)
			price.text = "Owned"

func _on_back_pressed() -> void:
	Global.save_game()
	SceneTransition.change_scene("res://Scenes/Menus/main_menu.tscn")
