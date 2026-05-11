extends CanvasLayer

@onready var time_out_menu: CanvasLayer = $"."
@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var container: Control = $Container

@onready var enemies_defeated_value: Label = $Container/DropMenu/InfoContainer/ValuesContainer/EnemiesDefeatedValue
@onready var money_made_value: Label = $Container/DropMenu/InfoContainer/ValuesContainer/MoneyMadeValue

func _process(_delta: float) -> void:
	if Global.level_time_left and Global.level_time_left <= 0:
		if get_tree().paused:
			return
		pause()

func pause() -> void:
	if get_tree().paused:
		return
		
	populate_values()
		
	container.mouse_filter = Control.MOUSE_FILTER_STOP
	container.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED
	
	time_out_menu.show()
	animation_player.play("blur")
	
	for hud in get_tree().get_nodes_in_group("HUD"):
		hud.hide()
		
	get_tree().paused = true

func populate_values():
	enemies_defeated_value.text = str(Global.enemies_killed_level)
	money_made_value.text = str(Global.money_made_level)


func _on_options_pressed() -> void:
	get_tree().paused = false
	animation_player.play_backwards("blur")
	SceneTransition.change_scene("res://Scenes/Menus/main_menu.tscn")


func _on_menu_pressed() -> void:
	get_tree().paused = false
	animation_player.play_backwards("blur")
	SceneTransition.change_scene("res://Scenes/Menus/main_menu.tscn")


func _on_restart_pressed() -> void:
	get_tree().paused = false
	animation_player.play_backwards("blur")
	get_tree().change_scene_to_file(Global.level_scenes_container[Global.current_level])
