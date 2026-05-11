extends AudioStreamPlayer

@onready var audio_menus: AudioStreamPlayer = $"."

var track_one = preload("res://Assets/Audio/MenuMusic/MenuTrack1.mp3")
var track_two= preload("res://Assets/Audio/MenuMusic/MenuTrack2.mp3")

func play_music():
	if not audio_menus.playing:
		if randf() > 0.5:
			audio_menus.stream = track_one
		else:
			audio_menus.stream = track_two
		audio_menus.play()

func stop_music():
	if audio_menus.playing:
		audio_menus.stream = null
		audio_menus.stop()
