extends Node

const SAVE_PATH := "user://save.json"

var game_sound = true
var enemies_killed_level = 0
var enemies_killed_total = 0
var money_made_level = 0
var money_made_total = 0
var player_is_dead = false
var guns = ["Pistol"] # "Pistol", "AK-47", "Sniper", "RocketLauncher"
var clothes = ["Ordinary"]
var equiped_clothes = "Ordinary"
var health_skill = 1
var speed_skill = 1
var jump_skill = 1
var characters = ["HashishTaqi"]
var selected_character = "HashishTaqi"
var current_level = 0
var highest_level = 0

var level_stats = {
	0 : [2, 500, 300],
	1 : [4, 1000, 300, preload("res://Assets/Guns/Guns/AK_Full.png"), "AK-47"],
	2 : [6, 1500, 400, preload("res://Assets/Guns/Guns/Sniper.png"), "Sniper"],
	3 : [8, 2500, 400],
	4 : [8, 3000, 400, preload("res://Assets/Guns/Guns/RocketLauncher.png"), "RocketLauncher"],
	5 : [10, 3000, 400],
	6 : [15, 3000, 400],
	7 : [14, 5000, 400]
}

var level_scenes_container = {
	0: "res://Scenes/Levels/level_0.tscn",
	1: "res://Scenes/Levels/level_1.tscn",
	2: "res://Scenes/Levels/level_2.tscn",
	3: "res://Scenes/Levels/level_3.tscn",
	4: "res://Scenes/Levels/level_4.tscn",
	5: "res://Scenes/Levels/level_5.tscn",
	6: "res://Scenes/Levels/level_6.tscn",
	7: "res://Scenes/Levels/level_7.tscn"
}

var show_win_menu = false
var level_time_left

var first_map_load = true
var first_level_load = true
var menu_tutorial_shown = false
var dev_mode = false
var master_volume := 1.0
var music_volume := 1.0
var sfx_volume := 1.0

func to_dict() -> Dictionary:
	return {
		"game_sound": game_sound,
		"enemies_killed_total": enemies_killed_total,
		"money_made_total": money_made_total,
		"guns": guns,
		"clothes": clothes,
		"equiped_clothes": equiped_clothes,
		"health_skill": health_skill,
		"speed_skill": speed_skill,
		"jump_skill": jump_skill,
		"characters": characters,
		"selected_character": selected_character,
		"highest_level": highest_level,
		"first_map_load": first_map_load,
		"menu_tutorial_shown": menu_tutorial_shown,
		"first_level_load": first_level_load,
		"dev_mode": dev_mode,
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume
	}

func from_dict(d: Dictionary) -> void:
	game_sound = d.get("game_sound", game_sound)
	enemies_killed_total = d.get("enemies_killed_total", enemies_killed_total)
	money_made_total = d.get("money_made_total", money_made_total)
	guns = d.get("guns", guns)
	clothes = d.get("clothes", clothes)
	equiped_clothes = d.get("equiped_clothes", equiped_clothes)
	health_skill = int(d.get("health_skill", health_skill))
	speed_skill = int(d.get("speed_skill", speed_skill))
	jump_skill = int(d.get("jump_skill", jump_skill))
	characters = d.get("characters", characters)
	selected_character = d.get("selected_character", selected_character)
	highest_level = max(0, int(d.get("highest_level", 0)))
	first_map_load = d.get("first_map_load", first_map_load)
	menu_tutorial_shown = d.get("menu_tutorial_shown", menu_tutorial_shown)
	first_level_load = d.get("first_level_load", first_level_load)
	dev_mode = d.get("dev_mode", dev_mode)
	master_volume = float(d.get("master_volume", master_volume))
	music_volume = float(d.get("music_volume", music_volume))
	sfx_volume = float(d.get("sfx_volume", sfx_volume))

func _ready() -> void:
	MobileAds.initialize()
	load_game()
	apply_audio_settings()

func _process(_delta: float) -> void:
	pass

func level_completed():
	if current_level > highest_level:
		highest_level = current_level
	show_win_menu = true
	
func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file for writing: " + SAVE_PATH)
		return

	var json_text := JSON.stringify(to_dict(), "\t")
	file.store_string(json_text)
	file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save found yet.")
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open save file for reading: " + SAVE_PATH)
		return

	var json_text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(json_text)
	if parsed == null:
		push_error("Save file JSON is invalid.")
		return

	from_dict(parsed)
	
func apply_audio_settings() -> void:
	var master_bus_index = AudioServer.get_bus_index("Master")
	var music_bus_index = AudioServer.get_bus_index("Music")
	var sfx_bus_index = AudioServer.get_bus_index("SFX")

	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(sfx_volume))
