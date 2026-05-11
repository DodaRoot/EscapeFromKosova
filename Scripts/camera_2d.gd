extends Camera2D


@onready var owner_of_camera: CharacterBody2D = $".."
@onready var camera_2d: Camera2D = $"."
var camera_offset = -200
var camera_zoom = 0.8
var shake := 0.0
var target_offset_x := 0.0
var base_offset := Vector2.ZERO
var shake_offset := Vector2.ZERO

func _ready() -> void:
	camera_2d.zoom = Vector2(camera_zoom, camera_zoom)
	camera_2d.offset.y = camera_offset

func _process(delta: float) -> void:
	if owner_of_camera.facing > 0:
		target_offset_x = 120
	else:
		target_offset_x = -120

	base_offset.x = lerp(base_offset.x, target_offset_x, 2 * delta)
	base_offset.y = camera_offset

	if shake > 0.01:
		shake_offset = Vector2(
			randf_range(-shake, shake),
			randf_range(-shake * 0.5, shake * 0.5)
		)
		shake = lerp(shake, 0.0, 60 * delta)
	else:
		shake_offset = Vector2.ZERO

	camera_2d.offset = base_offset + shake_offset

func start_camera_shake(intensity: float):
	shake = intensity

func camera_load(camera_zoom_param, camera_offset_param):
	camera_2d.zoom = Vector2(camera_zoom_param, camera_zoom_param)
	camera_2d.offset.y = camera_offset_param
	camera_zoom = camera_zoom_param
	camera_offset = camera_offset_param
