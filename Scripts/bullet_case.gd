extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_area_2d_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.is_in_group("Player") and body.health >= 0 and not animation_player.current_animation == "fade_out":
		
		var player = get_tree().get_first_node_in_group("Player")
		
		player.ak_bullets = 30
		player.ak_mag = 30
		player.sniper_bullets = 10
		player.sniper_mag = 3
		player.rocket_launcher_bullets = 3
		player.rocket_mag = 1
		
		animation_player.play("fade_out")
		await get_tree().create_timer(animation_player.current_animation_length).timeout

		queue_free()
