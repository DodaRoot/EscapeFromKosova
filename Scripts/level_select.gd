extends Control

@onready var levels: Control = $MapContainer/Levels
@onready var level_menu: CanvasLayer = $LevelMenu
@onready var tutorial: Control = $MapContainer/Levels/Level0/Tutorial
@onready var tutorial_rect: ColorRect = $TutorialRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var level_textures = [	preload("res://Assets/UI/Map/Level0.png"),
						preload("res://Assets/UI/Map/Level1.png"),
						preload("res://Assets/UI/Map/Level2.png"),
						preload("res://Assets/UI/Map/Level3.png"),
						preload("res://Assets/UI/Map/Level4.png"),
						preload("res://Assets/UI/Map/Level5.png"),
						preload("res://Assets/UI/Map/Level6.png"),
						preload("res://Assets/UI/Map/Level7.png")]
var levellocktexture = preload("res://Assets/UI/Map/LevelLock.png")

func _ready() -> void:
	MenuMusic.play_music()
	if Global.first_map_load:
		show_tutorial(true)
	else:
		show_tutorial(false)
	
	var i = 0
	for level in levels.get_children():
		if i <= Global.highest_level:
			level.get_child(0).texture = level_textures[i]
		else:
			level.get_child(0).texture = levellocktexture
			level.get_child(0).get_child(0).mouse_filter = MOUSE_FILTER_IGNORE
		i += 1
	
	await get_tree().create_timer(animation_player.current_animation_length).timeout
	animation_player.play("idle")

func _process(_delta: float) -> void:
	pass


func _on_level_button_pressed() -> void:
	if Global.first_map_load:
		Global.first_map_load = false
		show_tutorial(false)
	level_menu.show_info_menu(0, "Tutorial")

func _on_level1_button_pressed() -> void:
	level_menu.show_info_menu(1, "Prizren")

func _on_level2_button_pressed() -> void:
	level_menu.show_info_menu(2, "Ferizaj")

func _on_level3_button_pressed() -> void:
	level_menu.show_info_menu(3, "Gjakove")


func _on_level4_button_pressed() -> void:
	level_menu.show_info_menu(4, "Gjilan")


func _on_level5_button_pressed() -> void:
	level_menu.show_info_menu(5, "Peja")


func _on_level6_button_pressed() -> void:
	level_menu.show_info_menu(6, "Prishtine")


func _on_level7_button_pressed() -> void:
	level_menu.show_info_menu(7, "Mitrovice")


func _on_back_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/Menus/main_menu.tscn")

func show_tutorial(show_or_not):
	tutorial.visible = show_or_not
	tutorial_rect.visible = show_or_not
