extends CanvasLayer
@onready var pause_menu: CanvasLayer = $"."
@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var container: Control = $Container

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		if get_tree().paused:
			resume()
		else:
			pause()

func resume() -> void:
	if !get_tree().paused:
		return
		
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
		
	animation_player.play_backwards("blur")
	await animation_player.animation_finished
	
	for hud in get_tree().get_nodes_in_group("HUD"):
		hud.show()
		
	pause_menu.hide()
	get_tree().paused = false

func pause() -> void:
	if get_tree().paused:
		return
	container.mouse_filter = Control.MOUSE_FILTER_STOP
	container.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED
	
	pause_menu.show()
	animation_player.play("blur")
	
	for hud in get_tree().get_nodes_in_group("HUD"):
		hud.hide()
		
	get_tree().paused = true

func _on_resume_pressed() -> void:
	resume()

func _on_options_pressed() -> void:
	resume()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	animation_player.play_backwards("blur")
	SceneTransition.change_scene("res://Scenes/Menus/main_menu.tscn")

func _on_restart_pressed() -> void:
	Global.money_made_level = 0
	Global.enemies_killed_level = 0
	get_tree().paused = false
	animation_player.play_backwards("blur")
	get_tree().change_scene_to_file(Global.level_scenes_container[Global.current_level])
