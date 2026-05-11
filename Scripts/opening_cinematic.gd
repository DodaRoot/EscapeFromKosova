extends Node2D

@onready var scene_1: CanvasLayer = $Scene1
@onready var scene_2: CanvasLayer = $Scene2
@onready var scene_3: CanvasLayer = $Scene3
@onready var scene_4: CanvasLayer = $Scene4
@onready var texture_rect: TextureRect = $Scene2/TextureRect
@onready var scene2_label: Label = $Scene2/Label
@onready var scene3_label: Label = $Scene3/Label

var scenes: Array
var current_index: int = 0
var time_accum: float = 0.0
const SWITCH_TIME := 3.0

func _ready() -> void:
	MenuMusic.stop_music()
	scenes = [scene_1, scene_2, scene_3, scene_4]
	_show_only(current_index)

func _process(delta: float) -> void:
	time_accum += delta
	
	if time_accum >= SWITCH_TIME:
		time_accum -= SWITCH_TIME
		
		if current_index == scenes.size() - 1:
			get_tree().change_scene_to_file("res://Scenes/Levels/level_0.tscn")
			return
		
		current_index += 1
		_show_only(current_index)

func _show_only(index: int) -> void:
	for i in scenes.size():
		scenes[i].visible = (i == index)
	
	match index:
		1:
			_fade_in(texture_rect)
			_fade_in(scene2_label)
		2:
			_fade_in(scene3_label)

func _fade_in(node: CanvasItem) -> void:
	var mod := node.modulate
	mod.a = 0.0
	node.modulate = mod
	
	var tween := create_tween()
	tween.tween_property(node, "modulate:a", 1.0, 0.8) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
