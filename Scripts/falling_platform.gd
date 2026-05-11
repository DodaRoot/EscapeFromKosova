extends AnimatableBody2D

@export var fall_speed := 350.0
@export var sprite: Texture2D = null

@onready var sprite_2d: Sprite2D = $Sprite2D

var player_on_top := false

func _ready() -> void:
	if sprite:
		sprite_2d.texture = sprite

func _physics_process(delta: float) -> void:
	if player_on_top:
		global_position.y += fall_speed * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_on_top = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_on_top = false
