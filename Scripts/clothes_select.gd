extends Control

@onready var chlothing_container: VBoxContainer = $DefaultMenu/ScrollContainer/ChlothingContainer
@onready var money_had: Label = $DefaultMenu/MoneyText

func _ready() -> void:
	MenuMusic.play_music()
	money_had.text = str(Global.money_made_total)
	for clothing in chlothing_container.get_children():
		if Global.clothes.has(str(clothing.name)):
			var item_container = clothing.get_child(0)
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
			if Global.equiped_clothes == str(clothing.name):
				price.text = "Selected"
				button.get_child(1).text = ""
				button.visible = false

func buy_clothes(selected_clothes, price_value, first_time):
	reset_to_base()
	for clothing in chlothing_container.get_children():
		if str(clothing.name) == selected_clothes:
			Global.equiped_clothes = selected_clothes
			var item_container = clothing.get_child(0)
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
				Global.clothes.push_back(selected_clothes)

func reset_to_base():
	for chlothing in chlothing_container.get_children():
		if Global.clothes.has(str(chlothing.name)):
			var item_container = chlothing.get_child(0)
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

func _on_buy_ordinary_pressed() -> void:
	var price = 0
	var clothes = "Ordinary"
	if Global.clothes.has(clothes):
		buy_clothes(clothes, price, false)
	elif Global.money_made_total >= price:
		buy_clothes(clothes, price, true)

func _on_buy_shorts_pressed() -> void:
	var price = 1000
	var clothes = "Shorts"
	if Global.clothes.has(clothes):
		buy_clothes(clothes, price, false)
	elif Global.money_made_total >= price:
		buy_clothes(clothes, price, true)

func _on_buy_tradicional_pressed() -> void:
	var price = 1500
	var clothes = "Tradicional"
	if Global.clothes.has(clothes):
		buy_clothes(clothes, price, false)
	elif Global.money_made_total >= price:
		buy_clothes(clothes, price, true)

func _on_buy_suit_pressed() -> void:
	var price = 2500
	var clothes = "Suit"
	if Global.clothes.has(clothes):
		buy_clothes(clothes, price, false)
	elif Global.money_made_total >= price:
		buy_clothes(clothes, price, true)

func _on_buy_uq_kuniform_pressed() -> void:
	var price = 3000
	var clothes = "UQKuniform"
	if Global.clothes.has(clothes):
		buy_clothes(clothes, price, false)
	elif Global.money_made_total >= price:
		buy_clothes(clothes, price, true)

func _on_back_pressed() -> void:
	Global.save_game()
	SceneTransition.change_scene("res://Scenes/Menus/main_menu.tscn")
