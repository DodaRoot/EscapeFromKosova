extends CharacterBody2D

@onready var fps: Label = $HeliHud/Fps
@onready var helicopter: Sprite2D = $Helicopter
@onready var health_text: Label = $HeliHud/ContainerOfItems/Health/HealthText
@onready var bullets_text: Label = $HeliHud/ContainerOfItems/Bullets/BulletsText
@onready var money_text: Label = $HeliHud/ContainerOfItems/Money/MoneyText
@onready var time_text: Label = $HeliHud/ContainerOfItems/TimeContainer/TimeText
@onready var camera_2d_heli: Camera2D = $Camera2DHeli
@onready var muzzle: Marker2D = $Muzzle

@onready var audio_idle_fly: AudioStreamPlayer = $Audio_IdleFly

const ROCKET = preload("res://Scenes/Objects/bullets/heli_rocket.tscn")
const FLIGHT_TEX = preload("res://Assets/Tiles/Entities/Helicopter.png")
const STATIC_TEX = preload("res://Assets/Tiles/Entities/HelicopterStatic.png")

const GRAVITY_MULTIPLIER := 1.1
const LIFT_FORCE := 3200.0
const MAX_FALL_SPEED := 700.0
const MAX_RISE_SPEED := -1300.0

var health = 500
var bullets = 15
var speed := 900.0
var input_dir := 0.0
var facing := 1
var init_scale_x := 1.0
var camera

func _ready() -> void:
	if not camera:
		camera = get_tree().get_first_node_in_group("Camera")	
	camera.zoom = Vector2(0.5, 0.5)
	init_scale_x = scale.x

	if Global.dev_mode:
		fps.visible = true
	else:
		fps.visible = false

func _physics_process(delta: float) -> void:
	if Global.player_is_dead:
		return

	if Global.dev_mode:
		fps.text = "FPS: " + str(Engine.get_frames_per_second())
		
	if int(time_text.text) != Global.level_time_left:
		time_text.text = str(Global.level_time_left)
	health_text.text = str(health)
	bullets_text.text = str(bullets)
	money_text.text = str(Global.money_made_level)

	_handle_vertical_flight(delta)

	_handle_horizontal_movement()

	move_and_slide()
	_limit_height()
	
	if is_on_floor():
		helicopter.texture = STATIC_TEX
		if audio_idle_fly.playing:
			audio_idle_fly.stop()
	else:
		helicopter.texture = FLIGHT_TEX
		if not audio_idle_fly.playing:
			audio_idle_fly.play()
	
	if health <= 0:
		Global.player_is_dead = true

func _handle_vertical_flight(delta: float) -> void:
	velocity += get_gravity() * delta * GRAVITY_MULTIPLIER

	if Input.is_action_pressed("Jump"):
		velocity.y -= LIFT_FORCE * delta

	velocity.y = clamp(velocity.y, MAX_RISE_SPEED, MAX_FALL_SPEED)

func _handle_horizontal_movement() -> void:
	input_dir = Input.get_axis("MoveLeft", "MoveRight")
	input_dir = roundf(input_dir)

	if input_dir != 0.0 and not is_on_floor():
		velocity.x = input_dir * speed
		if input_dir > 0:
			helicopter.rotation_degrees = 5
			helicopter.flip_h = true
			facing = 1
		if input_dir < 0:
			helicopter.rotation_degrees = -5 
			helicopter.flip_h = false
			facing = -1
	else:
		helicopter.rotation_degrees = 0
		velocity.x = move_toward(velocity.x, 0.0, speed * 0.08)

func _limit_height() -> void:
	if global_position.y < -2000:
		global_position.y = -2000
		if velocity.y < 0:
			velocity.y = 0

func drop_rocket():
	var rocket = ROCKET.instantiate()
	rocket.global_position = muzzle.global_position
	rocket.ownerOfBullet = self
	get_tree().current_scene.add_child(rocket)


func _on_rocket_launcher_pressed() -> void:
	if bullets <= 0:
		return
	bullets -= 1
	drop_rocket()

func bullet_hit(damage: int) -> void:
	health -= damage
