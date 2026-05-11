extends Control

@onready var skill_bar_health: HBoxContainer = $DefaultMenu/Health/SkillBarHealth
@onready var skill_bar_speed: HBoxContainer = $DefaultMenu/Speed/SkillBarSpeed
@onready var skill_bar_jump: HBoxContainer = $DefaultMenu/Jump/SkillBarJump
@onready var price_health: Label = $DefaultMenu/Health/Price
@onready var money_health: Sprite2D = $DefaultMenu/Health/Price/Money
@onready var price_speed: Label = $DefaultMenu/Speed/Price
@onready var money_speed: Sprite2D = $DefaultMenu/Speed/Price/Money
@onready var price_jump: Label = $DefaultMenu/Jump/Price
@onready var money_jump: Sprite2D = $DefaultMenu/Jump/Price/Money
@onready var money_had: Label = $DefaultMenu/MoneyText

var skill_fill = preload("res://Assets/UI/MenuItems/SkillAdd.png")
var price = 50

func _ready() -> void:
	MenuMusic.play_music()
	money_had.text = str(Global.money_made_total)
	price_health.text = str(price * Global.health_skill)
	price_jump.text = str(price * Global.jump_skill)
	price_speed.text = str(price * Global.speed_skill)
	for n in Global.health_skill:
		skill_bar_health.get_child(n).texture = skill_fill
	if Global.health_skill == 7:
		price_health.text = "MAX"
		money_health.visible = false
	for n in Global.speed_skill:
		skill_bar_speed.get_child(n).texture = skill_fill
	if Global.speed_skill == 7:
		price_speed.text = "MAX"
		money_speed.visible = false
	for n in Global.jump_skill:
		skill_bar_jump.get_child(n).texture = skill_fill
	if Global.jump_skill == 7:
		price_jump.text = "MAX"
		money_jump.visible = false

func _on_add_speed_pressed() -> void:
	var current_price = price * Global.speed_skill
	if Global.money_made_total >= current_price and Global.speed_skill < 7:
		Global.speed_skill += 1
		Global.money_made_total -= current_price
		money_had.text = str(Global.money_made_total)
		if Global.speed_skill == 7:
			price_speed.text = "MAX"
			money_speed.visible = false
		else:
			price_speed.text = str(price * Global.speed_skill)
		for n in Global.speed_skill:
			skill_bar_speed.get_child(n).texture = skill_fill

func _on_add_jump_pressed() -> void:
	var current_price = price * Global.jump_skill
	if Global.money_made_total >= current_price and Global.jump_skill < 7:
		Global.jump_skill += 1
		Global.money_made_total -= current_price
		money_had.text = str(Global.money_made_total)
		if Global.jump_skill == 7:
			price_jump.text = "MAX"
			money_jump.visible = false
		else:
			price_jump.text = str(price * Global.jump_skill)
		for n in Global.jump_skill:
			skill_bar_jump.get_child(n).texture = skill_fill

func _on_add_health_pressed() -> void:
	var current_price = price * Global.health_skill
	if Global.money_made_total >= current_price and Global.health_skill < 7:
		Global.health_skill += 1
		Global.money_made_total -= current_price
		money_had.text = str(Global.money_made_total)
		if Global.health_skill == 7:
			price_health.text = "MAX"
			money_health.visible = false
		else:
			price_health.text = str(price * Global.health_skill)
		for n in Global.health_skill:
			skill_bar_health.get_child(n).texture = skill_fill

func _on_back_pressed() -> void:
	Global.save_game()
	SceneTransition.change_scene("res://Scenes/Menus/main_menu.tscn")
