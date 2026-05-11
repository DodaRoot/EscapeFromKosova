extends Button

@export var icon_default = preload("res://Assets/UI/Buttons/Play_Default.png")
@export var icon_pressed = preload("res://Assets/UI/Buttons/Play_Pressed.png")
@export var pressed_time = 0.1
@export var offset = 10

# Audio
@onready var audio_clicksound: AudioStreamPlayer = $Audio_CLICKSOUND
@export var click_sound = preload("res://Assets/Audio/Entities/ButtonClick.mp3")

func _ready() -> void:
	audio_clicksound.stream = click_sound
	audio_clicksound.owner = null
	icon = icon_default

func _on_pressed() -> void:
	if not audio_clicksound.playing:
		audio_clicksound.play()
	icon = icon_pressed
	position.y += offset
	await get_tree().create_timer(pressed_time).timeout
	icon = icon_default
	position.y -= offset
