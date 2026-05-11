extends Control

var master_bus_index = AudioServer.get_bus_index("Master")
var music_bus_index = AudioServer.get_bus_index("Music")
var sfx_bus_index = AudioServer.get_bus_index("SFX")

@onready var volume_slider_master: HSlider = $DefaultMenu/ScrollContainer/Container/SettingContainer/VolumeSliderMaster
@onready var volume_slider_music: HSlider = $DefaultMenu/ScrollContainer/Container/SettingContainer2/VolumeSliderMusic
@onready var volume_slider_sfx: HSlider = $DefaultMenu/ScrollContainer/Container/SettingContainer3/VolumeSliderSFX

@onready var button: Button = $DefaultMenu/ScrollContainer/Container/SettingContainer4/Button
var texture_button_on = preload("res://Assets/UI/MenuItems/OnButton.png")
var texture_button_off = preload("res://Assets/UI/MenuItems/OffButton.png")

func _ready() -> void:
	volume_slider_master.set_value_no_signal(Global.master_volume)
	volume_slider_music.set_value_no_signal(Global.music_volume)
	volume_slider_sfx.set_value_no_signal(Global.sfx_volume)

	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(Global.master_volume))
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(Global.music_volume))
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(Global.sfx_volume))

	if Global.dev_mode:
		button.icon = texture_button_on
		button.icon_default = texture_button_on
		button.icon_pressed = texture_button_on
	else:
		button.icon = texture_button_off
		button.icon_default = texture_button_off
		button.icon_pressed = texture_button_off

func _on_volume_slider_master_value_changed(value: float) -> void:
	Global.master_volume = value
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(value))

func _on_volume_slider_music_value_changed(value: float) -> void:
	Global.music_volume = value
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))

func _on_volume_slider_sfx_value_changed(value: float) -> void:
	Global.sfx_volume = value
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(value))

func _on_back_pressed() -> void:
	Global.save_game()
	SceneTransition.change_scene("res://Scenes/Menus/main_menu.tscn")

func _on_button_pressed() -> void:
	Global.dev_mode = !Global.dev_mode
	if Global.dev_mode:
		button.icon = texture_button_on
		button.icon_default = texture_button_on
		button.icon_pressed = texture_button_on
	elif not Global.dev_mode:
		button.icon = texture_button_off
		button.icon_default = texture_button_off
		button.icon_pressed = texture_button_off
