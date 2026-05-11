extends Node2D

const BULLET := preload("res://Scenes/Objects/bullets/rocket.tscn")

# Tuning
const MIN_MOUSE_DIST := 150.0
const ENEMY_FIRE_DIST := 1000.0
const MUZZLE_FLASH_TIME := 0.05
const CAMERA_SHAKE := 30.0
const BULLET_DAMAGE := 100

@export var fire_cd := 1.0
@export var mag_capacity := 1
@export var reload_time := 1.5
@export var enemy_cd := 6.0
@export var camera_offset := 0
@export var camera_zoom := 0.5

@onready var muzzle: Marker2D = $Muzzle
@onready var tank: CharacterBody2D = $".."
@onready var tank_barell: Node2D = $"."
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Audio
@onready var audio_rocketlaunch: AudioStreamPlayer = $Audio/Audio_ROCKETLAUNCH

var fire_timer := 0.0
var enemy_cd_time := 0.0
var turn_timer := 0.8

var base_scale := Vector2.ONE
var is_player := false
var is_reloading := false

var camera: Node = null
var hud: Node = null
var player_target: CharacterBody2D = null

var shoot_touch_index: int = -1
var shoot_touch_pos: Vector2 = Vector2.ZERO
var shoot_held := false
var _canvas_inv: Transform2D
var _rest_pos: Vector2

func _ready() -> void:
	is_player = tank.is_in_group("Player")
	_rest_pos = position
	if is_player:
		camera = get_tree().get_first_node_in_group("Camera")
		if camera and camera.has_method("camera_load"):
			camera.camera_load(camera_zoom, camera_offset)

		hud = get_tree().get_first_node_in_group("HUD")
		if hud and hud.has_method("play_reload"):
			hud.play_reload(false)

		if tank.rocket_mag <= 0:
			reload()


func _process(delta: float) -> void:
	if Global.player_is_dead:
		return

	fire_timer = maxf(0.0, fire_timer - delta)
	enemy_cd_time = maxf(0.0, enemy_cd_time - delta)

	if is_player:
		_canvas_inv = get_canvas_transform().affine_inverse()
		_handle_player(delta)
	else:
		_handle_enemy()


func _unhandled_input(event) -> void:
	if !is_player:
		return

	if event is InputEventScreenTouch:
		var t := event as InputEventScreenTouch

		if t.pressed:				
			if shoot_touch_index != -1:
				return

			shoot_touch_index = t.index
			shoot_touch_pos = _canvas_inv * t.position
			shoot_held = true

		else:
			if t.index == shoot_touch_index:
				shoot_touch_index = -1
				shoot_held = false

	elif event is InputEventScreenDrag:
		var d := event as InputEventScreenDrag
		if d.index == shoot_touch_index:
			shoot_touch_pos = _canvas_inv * d.position


func _handle_player(delta: float) -> void:
	if global_position.distance_squared_to(shoot_touch_pos) < MIN_MOUSE_DIST * MIN_MOUSE_DIST:
		return

	var wants_fire := shoot_touch_index != -1
	
	if wants_fire:
		_fire_at(shoot_touch_pos)
		tank.fire_mode = true
		turn_timer = 0.8
		return

	# Not firing
	if turn_timer > 0.0:
		turn_timer -= delta
	else:
		tank.fire_mode = false
		turn_timer = 0.8

func _handle_enemy() -> void:
	if !is_instance_valid(player_target):
		player_target = get_tree().get_first_node_in_group("Player")
		return
	
	var player_is_close = abs(player_target.global_position.x - global_position.x) < 600

	if player_target and not player_is_close:
		aim_at(player_target.global_position)

	if enemy_cd_time > 0.0:
		return

	if global_position.distance_squared_to(player_target.global_position) < tank.AGRO_DIST * tank.AGRO_DIST:
		if not player_is_close:
			_fire_at(player_target.global_position)
			enemy_cd_time = enemy_cd
	else:
		tank.fire_mode = false


func _fire_at(target: Vector2) -> void:
	if is_player:
		aim_at(target)
	shoot(target)

func shoot(_target: Vector2) -> void:
	if fire_timer > 0.0:
		return
	if is_player and tank.rocket_mag <= 0:
		return

	fire_timer = fire_cd
	tank.fire_mode = true

	if is_player:
		tank.rocket_mag -= 1

	var bullet = BULLET.instantiate()
	bullet.global_position = muzzle.global_position
	bullet.rotation = global_rotation
	bullet.ownerOfBullet = tank
	bullet.bulletDamage = BULLET_DAMAGE
	get_tree().current_scene.add_child(bullet)
	
	audio_rocketlaunch.play()

	if is_player and camera and camera.has_method("start_camera_shake"):
		camera.start_camera_shake(CAMERA_SHAKE)
	animated_sprite_2d.play("shoot")
	cpu_particles_2d.restart()
	cpu_particles_2d.emitting = true
	flash()

	if is_player and tank.rocket_mag <= 0:
		reload()


func aim_at(target: Vector2) -> void:
	var to_target = target - tank_barell.global_position
	var target_angle = to_target.angle()

	var base_angle = tank.global_rotation

	var relative_angle = wrapf(target_angle - base_angle, -PI, PI)

	var max_angle = deg_to_rad(50)
	relative_angle = clamp(relative_angle, -max_angle, max_angle)

	tank_barell.global_rotation = base_angle + relative_angle

	var facing_left = target.x < global_position.x
	if facing_left:
		tank.transform.x = Vector2(-1, 0)
		tank.facing = -1
	else:
		tank.transform.x = Vector2(1, 0)
		tank.facing = 1

func reload() -> void:
	if is_reloading:
		return

	is_reloading = true
	fire_timer = reload_time

	if tank and tank.has_method("play_reload"):
		tank.play_reload()

	await get_tree().create_timer(reload_time).timeout

	tank.rocket_mag += mag_capacity

	is_reloading = false

func flash() -> void:
	point_light_2d.energy = 0.4
	await get_tree().create_timer(MUZZLE_FLASH_TIME).timeout
	point_light_2d.energy = 0.0
