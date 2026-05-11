extends CanvasLayer

@onready var title: Label = $Container/DropMenu/Title
@onready var enemies_on_level_value: Label = $Container/DropMenu/InfoContainer/ValuesContainer/EnemiesOnLevelValue
@onready var money_on_level_value: Label = $Container/DropMenu/InfoContainer/ValuesContainer/MoneyOnLevelValue
@onready var time_on_level_value: Label = $Container/DropMenu/InfoContainer/ValuesContainer/TimeOnLevelValue
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var reward_icon: TextureRect = $Container/DropMenu/RewardsContainer/ValuesContainer/RewardIcon

var current_level

func show_info_menu(level, level_title):
	if not Global.level_stats.has(level):
		return
	
	current_level = level
	title.text = level_title
	enemies_on_level_value.text = str(Global.level_stats[level][0])
	money_on_level_value.text = str(Global.level_stats[level][1])
	time_on_level_value.text = str(round(Global.level_stats[level][2]))

	if Global.level_stats[level].size() > 3:
		print(Global.level_stats[level])
		reward_icon.texture = Global.level_stats[level][3]
	else:
		reward_icon.texture = null

	animation_player.play("blur")

func _on_back_pressed() -> void:
	Global.current_level = 0
	title.text = "None selected"
	enemies_on_level_value.text = ""
	money_on_level_value.text = ""
	time_on_level_value.text = ""
	reward_icon.texture = null
	animation_player.play_backwards("blur")

func _on_play_pressed() -> void:
	Global.player_is_dead = false
	Global.current_level = current_level
	if Global.first_level_load:
		SceneTransition.change_scene("res://Scenes/Menus/opening_cinematic.tscn")
		return
	SceneTransition.change_scene(Global.level_scenes_container[current_level])
