extends AnimatableBody2D

@export var speed = 200
@export var distance = 600
@export var type = "h"
@export var direction = 1
@export var sprite: Texture2D = null

@onready var sprite_2d: Sprite2D = $Sprite2D

var start_pos

func _ready():
	if sprite:
		sprite_2d.texture = sprite
	if type == "h":
		start_pos = position.x
	elif type == "v":
		start_pos = position.y

func _physics_process(delta: float) -> void:
	var axis_is_horizontal = (type == "h")
	var current_pos = position.x if axis_is_horizontal else position.y
	
	current_pos += direction * speed * delta
	
	if direction > 0 and current_pos >= start_pos + distance:
		start_pos = current_pos
		direction = -1
	elif direction < 0 and current_pos <= start_pos - distance:
		start_pos = current_pos
		direction = 1
	
	if axis_is_horizontal:
		position.x = current_pos
	else:
		position.y = current_pos
