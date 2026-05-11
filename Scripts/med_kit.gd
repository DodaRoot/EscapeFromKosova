extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_area_2d_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.is_in_group("Player") and body.health >= 0 and not animation_player.current_animation == "fade_out":
		
		var player = get_tree().get_first_node_in_group("Player")
		
		player.health = 100 + (Global.health_skill - 1) * 20
		
		animation_player.play("fade_out")
		await get_tree().create_timer(animation_player.current_animation_length).timeout

		queue_free()
