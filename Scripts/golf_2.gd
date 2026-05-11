extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_left_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		animation_player.play("lean_left")

func _on_right_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		animation_player.play("lean_right")

func _on_left_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		animation_player.play("RESET")

func _on_right_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		animation_player.play("RESET")
