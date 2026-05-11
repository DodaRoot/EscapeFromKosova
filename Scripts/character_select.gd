extends Control

@onready var characters_container: VBoxContainer = $DefaultMenu/ScrollContainer/CharactersContainer
@onready var money_had: Label = $DefaultMenu/MoneyText

func _ready() -> void:
	MenuMusic.play_music()
	money_had.text = str(Global.money_made_total)
	for character in characters_container.get_children():
		if Global.characters.has(str(character.name)):
			var item_container = character.get_child(0)
			var texture = item_container.get_child(0)
			var text = item_container.get_child(1)
			var button = item_container.get_child(2)
			var button_text = button.get_child(1)
			var price = text.get_child(2)
			var price_icon = price.get_child(0)
			price_icon.visible = false
			texture.modulate = Color8(255, 255, 255, 255)
			button_text.text = "Select"
			button.visible = true
			price.text = "Owned"
			if Global.selected_character == str(character.name):
				price.text = "Selected"
				button.get_child(1).text = ""
				button.visible = false

func buy_character(selected_character, price_value, first_time):
	reset_to_base()
	for character in characters_container.get_children():
		if str(character.name) == selected_character:
			Global.selected_character = selected_character
			var item_container = character.get_child(0)
			var texture = item_container.get_child(0)
			var text = item_container.get_child(1)
			var button = item_container.get_child(2)
			var button_text = button.get_child(1)
			var price = text.get_child(2)
			var price_icon = price.get_child(0)
			price_icon.visible = false
			texture.modulate = Color8(255, 255, 255, 255)
			price.text = "Selected"
			button.visible = false
			button_text.text = ""
			if first_time:
				Global.money_made_total -= price_value
				money_had.text = str(Global.money_made_total)
				Global.characters.push_back(selected_character)

func _on_buy_hashish_pressed() -> void:
	var price = 0
	var character = "HashishTaqi"
	if Global.characters.has(character):
		buy_character(character, price, false)
	elif Global.money_made_total >= price:
		buy_character(character, price, true)

func _on_buy_dr_rugova_pressed() -> void:
	var price = 2000
	var character = "DrRugova"
	if Global.characters.has(character):
		buy_character(character, price, false)
	elif Global.money_made_total >= price:
		buy_character(character, price, true)

func _on_buy_mr_bini_pressed() -> void:
	var price = 2000
	var character = "MrBini"
	if Global.characters.has(character):
		buy_character(character, price, false)
	elif Global.money_made_total >= price:
		buy_character(character, price, true)

func _on_buy_rambo_pressed() -> void:
	var price = 2000
	var character = "Rambo"
	if Global.characters.has(character):
		buy_character(character, price, false)
	elif Global.money_made_total >= price:
		buy_character(character, price, true)

func _on_buy_komandanti_legjendar_pressed() -> void:
	var price = 2300
	var character = "KomandantiLegjendar"
	if Global.characters.has(character):
		buy_character(character, price, false)
	elif Global.money_made_total >= price:
		buy_character(character, price, true)

func reset_to_base():
	for character in characters_container.get_children():
		if Global.characters.has(str(character.name)):
			var item_container = character.get_child(0)
			var texture = item_container.get_child(0)
			var text = item_container.get_child(1)
			var button = item_container.get_child(2)
			var button_text = button.get_child(1)
			var price = text.get_child(2)
			var price_icon = price.get_child(0)
			price_icon.visible = false
			texture.modulate = Color8(255, 255, 255, 255)
			button_text.text = "Select"
			button.visible = true
			price.text = "Owned"

func _on_back_pressed() -> void:
	Global.save_game()
	SceneTransition.change_scene("res://Scenes/Menus/main_menu.tscn")
