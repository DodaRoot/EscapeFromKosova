extends TouchScreenButton

@export var pressed_time = 0.1
@export var pressed_margin = 10

func _on_pressed() -> void:
	position.y += pressed_margin

func _on_released() -> void:
	position.y -= pressed_margin
