extends CanvasLayer

@onready var Player: CharacterBody2D = $".."
@onready var health_text: Label = $ContainerOfItems/Health/HealthText
@onready var bullets_text: Label = $ContainerOfItems/Bullets/BulletsText
@onready var money_text: Label = $ContainerOfItems/Money/MoneyText
@onready var pistol: TouchScreenButton = $ContainerOfControlls/Pistol
@onready var ak_47: TouchScreenButton = $"ContainerOfControlls/AK-47"
@onready var sniper: TouchScreenButton = $ContainerOfControlls/Sniper
@onready var rocket_launcher: TouchScreenButton = $ContainerOfControlls/RocketLauncher
@onready var time_text: Label = $ContainerOfItems/TimeContainer/TimeText
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var tutorial_container: Node = $TutorialContainer
@onready var tutorial_items: CanvasLayer = $TutorialContainer/TutorialItems
@onready var tutorial_settings: CanvasLayer = $TutorialContainer/TutorialSettings
@onready var tutorial_jump_and_guns: CanvasLayer = $TutorialContainer/TutorialJumpAndGuns
@onready var tutorial_move_controls: CanvasLayer = $TutorialContainer/TutorialMoveControls
@onready var tutorial_shoot: CanvasLayer = $TutorialContainer/TutorialShoot
@onready var container_of_items: Control = $ContainerOfItems
@onready var container_of_settings: Control = $ContainerOfSettings
@onready var container_of_controlls: Control = $ContainerOfControlls
@onready var container_of_jump_and_guns: Control = $ContainerOfJumpAndGuns

@onready var fps: Label = $Fps
var _ad_view : AdView

var selected_bullets
var time_to_tutorial = 2.0

func _ready() -> void:
	_load_ads()
	if Global.dev_mode:
		fps.visible = true
	else:
		fps.visible = false
	
	hide_tutorials()
	if Global.first_level_load:
		show_tutorials()
	selected_bullets = "glock"
	if Global.guns.size() > 1:
		pistol.visible = true
	if Global.guns.has("AK-47"):
		ak_47.visible = true
	if Global.guns.has("Sniper"):
		sniper.visible = true
	if Global.guns.has("RocketLauncher"):
		rocket_launcher.visible = true

func _process(_delta: float) -> void:
	if Global.dev_mode:
		fps.text = "FPS: " + str(Engine.get_frames_per_second())
	
	if int(time_text.text) != Global.level_time_left:
		time_text.text = str(Global.level_time_left)
		
	health_text.text = str(Player.health)
	money_text.text = str(Global.money_made_level)
	if selected_bullets != null:
		if selected_bullets == "glock":
			bullets_text.text = str(Player.glock_mag) + "/" + " ∞"
		if selected_bullets == "ak":
			bullets_text.text = str(Player.ak_mag) + "/" + str(Player.ak_bullets)
		if selected_bullets == "sniper":
			bullets_text.text = str(Player.sniper_mag) + "/" + str(Player.sniper_bullets)
		if selected_bullets == "rocket":
			bullets_text.text = str(Player.rocket_mag) + "/" + str(Player.rocket_launcher_bullets)

func _on_pistol_pressed() -> void:
	const GLOCK = preload("res://Scenes/Guns/glock.tscn")
	Player.change_weapon(GLOCK)
	selected_bullets = "glock"

func _on_ak_47_pressed() -> void:
	const AK = preload("res://Scenes/Guns/ak_47.tscn")
	Player.change_weapon(AK)
	selected_bullets = "ak"

func _on_sniper_pressed() -> void:
	const SNIPER = preload("res://Scenes/Guns/sniper.tscn")
	Player.change_weapon(SNIPER)
	selected_bullets = "sniper"


func _on_rocket_launcher_pressed() -> void:
	const ROCKET_LAUNCHER = preload("res://Scenes/Guns/rocket_launcher.tscn")
	Player.change_weapon(ROCKET_LAUNCHER)
	selected_bullets = "rocket"

func play_reload(play = true):
	if play:
		if not animation_tree.get("parameters/PlayReload/active"):
			animation_tree.set("parameters/PlayReload/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	else:
		if animation_tree.get("parameters/PlayReload/active"):
			animation_tree.set("parameters/PlayReload/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

func show_tutorials():
	await get_tree().create_timer(time_to_tutorial).timeout
	hide_hud()
	container_of_items.visible = true
	tutorial_items.visible = true
	get_tree().paused = true

func hide_tutorials():
	for item in tutorial_container.get_children():
		item.visible = false
		
func hide_hud():
	container_of_items.visible = false
	container_of_settings.visible = false
	container_of_jump_and_guns.visible = false
	container_of_controlls.visible = false
	fps.visible = false
	
func show_hud():
	container_of_items.visible = true
	container_of_settings.visible = true
	container_of_jump_and_guns.visible = true
	container_of_controlls.visible = true
	fps.visible = Global.dev_mode

func _on_items_next_pressed() -> void:
	hide_tutorials()
	hide_hud()
	container_of_settings.visible = true
	tutorial_settings.visible = true


func _on_settings_next_pressed() -> void:
	hide_tutorials()
	hide_hud()
	container_of_jump_and_guns.visible = true
	tutorial_jump_and_guns.visible = true


func _on_jump_guns_next_pressed() -> void:
	hide_tutorials()
	hide_hud()
	container_of_controlls.visible = true
	tutorial_move_controls.visible = true


func _on_move_controls_next_pressed() -> void:
	hide_tutorials()
	hide_hud()
	tutorial_shoot.visible = true

func _on_shoot_next_pressed() -> void:
	get_tree().paused = false
	Global.first_level_load = false
	hide_tutorials()
	show_hud()
	Global.save_game()
	
func _create_ad_view() -> void:
	if _ad_view:
		destroy_ad_view()

	var unit_id : String
	if OS.get_name() == "Android":
		# Test addmob unit ID : ca-app-pub-3940256099942544/6300978111
		# My addmob unit ID : ca-app-pub-5260800330186130/3514415812
		unit_id = "ca-app-pub-5260800330186130/3514415812"

	_ad_view = AdView.new(unit_id, AdSize.BANNER, AdPosition.Values.BOTTOM)

func destroy_ad_view() -> void:
	if _ad_view:
		_ad_view.destroy()
		_ad_view = null

func _register_ad_listener() -> void:
	if _ad_view != null:
		var ad_listener := AdListener.new()

		ad_listener.on_ad_loaded = func():
			print("Ad loaded")

		ad_listener.on_ad_failed_to_load = func(error):
			print("Ad failed: ", error.message)

		_ad_view.ad_listener = ad_listener

func _load_ads():
	if _ad_view == null:
		_create_ad_view()
		_register_ad_listener()
	var ad_request := AdRequest.new()
	_ad_view.load_ad(ad_request)
	
func _exit_tree():
	destroy_ad_view()
