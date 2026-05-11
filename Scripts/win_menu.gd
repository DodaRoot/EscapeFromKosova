extends CanvasLayer

@onready var win_menu: CanvasLayer = self
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var container: Control = $Container

@onready var enemies_defeated_value: Label = $Container/DropMenu/InfoContainer/ValuesContainer/EnemiesDefeatedValue
@onready var money_made_value: Label = $Container/DropMenu/InfoContainer/ValuesContainer/MoneyMadeValue
@onready var time_value: Label = $Container/DropMenu/InfoContainer/ValuesContainer/TimeValue
@onready var next_button: Button = $Container/DropMenu/VBoxContainer/Next
@onready var button_text: Label = $Container/DropMenu/VBoxContainer/Next/ButtonText

func _ready() -> void:
	next_button.disabled = !Global.menu_tutorial_shown

func _process(_delta: float) -> void:
	if Global.show_win_menu and not get_tree().paused:
		pause_menu()

func pause_menu() -> void:
	if get_tree().paused:
		return

	populate_values()
	update_next_button()

	container.mouse_filter = Control.MOUSE_FILTER_STOP
	container.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED

	win_menu.show()
	animation_player.play("blur")
	await animation_player.animation_finished

	calculate_stars_and_populate()

	for hud in get_tree().get_nodes_in_group("HUD"):
		hud.hide()

	get_tree().paused = true

func populate_values() -> void:
	enemies_defeated_value.text = str(Global.enemies_killed_level)
	money_made_value.text = str(Global.money_made_level)
	time_value.text = str(Global.level_time_left)

func update_next_button() -> void:
	next_button.visible = has_next_level()

func has_next_level() -> bool:
	return Global.current_level + 1 < Global.level_scenes_container.size()

func calculate_stars_and_populate() -> void:
	var level_data = Global.level_stats[Global.current_level]

	var time_star = (round(level_data[2]) / 2.0) < Global.level_time_left
	var enemy_star = Global.enemies_killed_level >= level_data[0]
	var money_star = Global.money_made_level >= level_data[1]

	populate_stars(time_star, enemy_star, money_star)

func populate_stars(time_star: bool, enemy_star: bool, money_star: bool) -> void:
	var stars = int(time_star) + int(enemy_star) + int(money_star)

	match stars:
		3:
			animation_player.play("three_star")
		2:
			animation_player.play("two_star")
		1:
			animation_player.play("one_star")

func _on_win_menu_pressed() -> void:
	var current_level_data = Global.level_stats[Global.current_level]
	_change_highest_level()
	finish_level()
	if current_level_data.size() > 4:
		get_reward(current_level_data[4])
	Global.save_game()
	SceneTransition.change_scene("res://Scenes/Menus/main_menu.tscn")

func _on_win_next_pressed() -> void:
	if not has_next_level():
		return

	var current_level_data = Global.level_stats[Global.current_level]

	if current_level_data.size() > 4:
		get_reward(current_level_data[4])

	_change_highest_level()
	finish_level()

	var next_level = Global.current_level + 1
	Global.current_level = next_level

	Global.save_game()
	SceneTransition.change_scene(Global.level_scenes_container[next_level])

func finish_level() -> void:
	Global.money_made_total += Global.money_made_level
	Global.money_made_level = 0
	Global.enemies_killed_total += Global.enemies_killed_level
	Global.enemies_killed_level = 0
	Global.show_win_menu = false
	get_tree().paused = false
	animation_player.play_backwards("blur")

func _change_highest_level() -> void:
	if Global.current_level == Global.highest_level:
		Global.highest_level += 1

func get_reward(reward) -> void:
	if not Global.guns.has(reward):
		Global.guns.append(reward)
