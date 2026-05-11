extends Node2D

@onready var spawn_point: Node2D = $SpawnPoint
@onready var timer: Timer = $Timer

@export var heli_player = false
@export var t_player = false

var helicopter_player = preload("res://Scenes/Characters/Clothing/heli_player.tscn")
var tank_player = preload("res://Scenes/Characters/Clothing/tank_player.tscn")

var clothes = {
	"Ordinary" : preload("res://Scenes/Characters/Clothing/ordinary_clothing.tscn"),
	"Shorts" : preload("res://Scenes/Characters/Clothing/shorts_clothing.tscn"),
	"Tradicional" : preload("res://Scenes/Characters/Clothing/tradicional_clothing.tscn"),
	"Suit" : preload("res://Scenes/Characters/Clothing/suit_clothing.tscn"),
	"UQKuniform" : preload("res://Scenes/Characters/Clothing/uqk_clothing.tscn")
}

func _ready():
	MenuMusic.stop_music()
	var selected_clothes = Global.equiped_clothes
	if not clothes.has(selected_clothes):
		push_warning("No character selected!")
		return
	
	var player
	if heli_player:
		player = helicopter_player.instantiate()
	elif t_player:
		player = tank_player.instantiate()
	else:
		player = clothes[selected_clothes].instantiate()
	
	add_child(player)

	player.global_position = spawn_point.global_position
	timer.wait_time = Global.level_stats[Global.current_level][2]
	timer.timeout.connect(timer.queue_free)
	timer.start()

func _process(_delta: float) -> void:
	if timer and int(timer.time_left) >= 0 and not int(timer.time_left) == Global.level_time_left:
		Global.level_time_left = int(timer.time_left)
