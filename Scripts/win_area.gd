extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@export var sprite = preload("res://Assets/Tiles/Entities/Jeep.png")
@export var sprite_size = 4
@export var game_win = false

func _ready() -> void:
	if sprite_2d.texture != sprite:
		sprite_2d.scale = Vector2(sprite_size, sprite_size)
	sprite_2d.texture = sprite

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and game_win:
		game_completed()
	elif body.is_in_group("Player"):
		Global.level_completed()

func game_completed():
	SceneTransition.change_scene("res://Scenes/Menus/game_credits.tscn")
