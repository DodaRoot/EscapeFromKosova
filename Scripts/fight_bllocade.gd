extends StaticBody2D

@export var level_boss : CharacterBody2D

func _process(_delta: float) -> void:
	if not level_boss:
		queue_free()
