extends AudioStreamPlayer

func _ready() -> void:
	connect("finished", on_finished)

func on_finished():
	queue_free()
