extends Control

@onready var character_select: Button = $ContentContainer/RightButtons/CharacterSelect
@onready var skills_select: Button = $ContentContainer/RightButtons/SkillsSelect
@onready var gun_select: Button = $ContentContainer/LeftButtons/GunSelect
@onready var clothes_select: Button = $ContentContainer/LeftButtons/ClothesSelect
@onready var guns: Control = $Tutorial/Guns
@onready var clothing: Control = $Tutorial/Clothing
@onready var characters: Control = $Tutorial/Characters
@onready var skills: Control = $Tutorial/Skills
@onready var main_buttons: Control = $ContentContainer/MainButtons
@onready var tutorial: Control = $Tutorial

var tutorial_buttons := []
var tutorial_text := []

func _ready() -> void:
	tutorial.visible = false
	MenuMusic.play_music()
	if not Global.menu_tutorial_shown and not Global.first_level_load:
		Global.menu_tutorial_shown = true
		tutorial_buttons = [character_select, skills_select, gun_select, clothes_select]
		tutorial_text = [guns, clothing, characters, skills]
		main_menu_tutorial()

func _on_gun_select_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/Menus/gun_select.tscn")


func _on_clothes_select_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/Menus/clothes_select.tscn")


func _on_play_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/Menus/level_select.tscn")


func _on_options_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/Menus/settings.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_character_select_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/Menus/character_select.tscn")


func _on_skills_select_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/Menus/skills.tscn")

func main_menu_tutorial():
	tutorial.visible = true
	hide_all_buttons(false)
	disable_enable_all_buttons(true)
	guns_tutorial()

func guns_tutorial():
	hide_all_buttons(false)
	gun_select.visible = true
	guns.visible = true
	await get_tree().create_timer(2.0).timeout
	clothing_tutorial()
	
func clothing_tutorial():
	hide_all_buttons(false)
	clothes_select.visible = true
	clothing.visible = true
	await get_tree().create_timer(2.0).timeout
	character_tutorial()
	
func character_tutorial():
	hide_all_buttons(false)
	character_select.visible = true
	characters.visible = true
	await get_tree().create_timer(2.0).timeout
	skills_tutorial()
	
func skills_tutorial():
	hide_all_buttons(false)
	skills_select.visible = true
	skills.visible = true
	await get_tree().create_timer(2.0).timeout
	hide_all_buttons(true)
	disable_enable_all_buttons(false)
	tutorial.visible = false
	Global.menu_tutorial_shown = true
	Global.save_game()

func disable_enable_all_buttons(enable_disable):
	for button in tutorial_buttons:
		button.disabled = enable_disable

func hide_all_buttons(visible_notvisible):
	main_buttons.visible = visible_notvisible
	for button in tutorial_buttons:
		button.visible = visible_notvisible
	for button in tutorial_text:
		button.visible = visible_notvisible
