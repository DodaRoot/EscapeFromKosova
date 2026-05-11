extends CharacterBody2D

@export var fps: Label
@export var health_text: Label
@export var bullets_text: Label
@export var money_text: Label
@export var time_text: Label
@export var animation_player: AnimationPlayer

@onready var tank_barell: Node2D = $TankBarell

@export var health = 100
@export var speed = 300.0

const PUSH := 100.0

var rocket_mag := 1
var input_dir := 0.0
var fire_mode := false
var facing = 1
var camera

func _ready() -> void:
	bullets_text.text = str("∞")
	
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
	money_text.text = str(Global.money_made_level)
	
	if !is_on_floor():
		velocity += get_gravity() * 2 * delta
		
	_handle_movement(delta)
	move_and_slide()
	_push_rigid_bodies()
	
	if health <= 0:
		Global.player_is_dead = true

func _handle_movement(_delta: float) -> void:
	input_dir = Input.get_axis("MoveLeft", "MoveRight")
	input_dir = roundf(input_dir)

	if input_dir != 0.0:
		velocity.x = input_dir * speed
		if is_on_floor() and !fire_mode:
			if velocity.x > 0:
				transform.x = Vector2(1.0, 0.0)
				facing = 1
			elif velocity.x < 0:
				transform.x = Vector2(-1.0, 0.0)
				facing = -1
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)

func _push_rigid_bodies() -> void:
	var count := get_slide_collision_count()
	for i in count:
		var c := get_slide_collision(i)
		var body := c.get_collider()
		if body is RigidBody2D:
			body.apply_central_impulse(-c.get_normal() * PUSH)

func play_reload():
	animation_player.play("reload")

func bullet_hit(damage: int) -> void:
	health -= damage
