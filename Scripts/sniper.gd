extends Node2D

const BULLET := preload("res://Scenes/Objects/bullets/sniper_bullet.tscn")

# Tuning
const MIN_MOUSE_DIST := 150.0
const ENEMY_FIRE_DIST := 1000.0
const MUZZLE_FLASH_TIME := 0.05
const CAMERA_SHAKE := 30.0
const BULLET_DAMAGE := 50

@export var fire_cd := 0.1
@export var mag_capacity := 1
@export var reload_time := 1.5
@export var enemy_cd := 3.0
@export var camera_offset := 0
@export var camera_zoom := 0.5
@export var recoil_pixels := 8.0
@export var recoil_time := 0.08

@onready var muzzle: Marker2D = $Muzzle
@onready var left_hand: Bone2D = $"../../.."
@onready var lower_left_arm: Bone2D = $"../../../.."
@onready var upper_left_arm: Bone2D = $"../../../../.."
@onready var skeleton_2d: Skeleton2D = $"../../../../../../../.."
@onready var owner_of_gun: CharacterBody2D = $"../../../../../../../../.."
@onready var gun_point: Bone2D = $"../.."
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
# Audio
@onready var audio_snipershot: AudioStreamPlayer = $Audio/Audio_SNIPERSHOT
@onready var audio_reload: AudioStreamPlayer = $Audio/Audio_RELOAD

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
var _recoil_tween: Tween

func _ready() -> void:
	_clamp_bones()
	base_scale = skeleton_2d.scale
	is_player = owner_of_gun.is_in_group("Player")
	_rest_pos = position
	if is_player:
		camera = get_tree().get_first_node_in_group("Camera")
		if camera and camera.has_method("camera_load"):
			camera.camera_load(camera_zoom, camera_offset)

		hud = get_tree().get_first_node_in_group("HUD")
		if hud and hud.has_method("play_reload"):
			hud.play_reload(false)

		if owner_of_gun.sniper_mag <= 0 and owner_of_gun.sniper_bullets > 0:
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
		owner_of_gun.fire_mode = true
		turn_timer = 0.8
		return

	# Not firing
	owner_of_gun.stop_fire_anim()
	if turn_timer > 0.0:
		turn_timer -= delta
	else:
		owner_of_gun.fire_mode = false
		turn_timer = 0.8
		owner_of_gun.stop_fire_anim()


func _handle_enemy() -> void:
	if enemy_cd_time > 0.0:
		return

	if !is_instance_valid(player_target):
		player_target = get_tree().get_first_node_in_group("Player")
		return

	if global_position.distance_squared_to(player_target.global_position) < owner_of_gun.AGRO_DIST * owner_of_gun.AGRO_DIST:
		_fire_at(player_target.global_position)
		enemy_cd_time = enemy_cd
	else:
		owner_of_gun.fire_mode = false


func _fire_at(target: Vector2) -> void:
	aim_at(target)
	shoot(target)


func shoot(target: Vector2) -> void:
	if fire_timer > 0.0:
		return
	if is_player and owner_of_gun.sniper_mag <= 0:
		return

	fire_timer = fire_cd
	owner_of_gun.fire_mode = true

	if is_player:
		owner_of_gun.play_fire_anim()

	if is_player:
		owner_of_gun.sniper_mag -= 1

	var bullet = BULLET.instantiate()
	bullet.global_position = muzzle.global_position
	bullet.rotation = global_rotation
	bullet.ownerOfBullet = owner_of_gun
	bullet.bulletDamage = BULLET_DAMAGE
	get_tree().current_scene.add_child(bullet)
	
	audio_snipershot.play()

	if is_player and camera and camera.has_method("start_camera_shake"):
		camera.start_camera_shake(CAMERA_SHAKE)
	animated_sprite_2d.play("shoot")
	cpu_particles_2d.restart()
	cpu_particles_2d.emitting = true
	flash()
	_recoil(target)

	if is_player and owner_of_gun.sniper_mag <= 0:
		reload()


func aim_at(target: Vector2) -> void:
	var facing_left := target.x < global_position.x
	skeleton_2d.scale.x = absf(base_scale.x) * (-1.0 if facing_left else 1.0)

	var tilt := left_hand.get_angle_to(target)
	lower_left_arm.rotate(tilt * 0.2)
	gun_point.rotate(gun_point.get_angle_to(target) * 0.1)
	if global_rotation_degrees < 0.0:
		upper_left_arm.rotate(tilt * 0.3)

	left_hand.look_at(target)
	_clamp_bones()


func _clamp_bones() -> void:
	_clamp_rot(upper_left_arm, -50.0, 0.0)
	_clamp_rot(lower_left_arm, -40.0, 15.0)
	_clamp_rot(left_hand, -70.0, 70.0)


func _clamp_rot(bone: Bone2D, min_d: float, max_d: float) -> void:
	bone.rotation_degrees = clampf(bone.rotation_degrees, min_d, max_d)


func reload() -> void:
	if is_reloading or owner_of_gun.sniper_bullets <= 0:
		return

	if not audio_reload.playing:
		audio_reload.play()

	is_reloading = true
	fire_timer = reload_time

	if hud and hud.has_method("play_reload"):
		hud.play_reload()
	if animation_player:
		animation_player.play("reload")

	await get_tree().create_timer(reload_time).timeout

	var amount_to_fill = mag_capacity - owner_of_gun.sniper_mag
	var amount_available = min(amount_to_fill, owner_of_gun.sniper_bullets)

	owner_of_gun.sniper_mag += amount_available
	owner_of_gun.sniper_bullets -= amount_available

	is_reloading = false


func flash() -> void:
	point_light_2d.energy = 0.4
	await get_tree().create_timer(MUZZLE_FLASH_TIME).timeout
	point_light_2d.energy = 0.0

func _recoil(target: Vector2) -> void:
	var dir := (target - muzzle.global_position).normalized()
	var kick := -dir * recoil_pixels  # backwards

	if _recoil_tween and _recoil_tween.is_valid():
		_recoil_tween.kill()

	position = _rest_pos
	_recoil_tween = create_tween()
	_recoil_tween.tween_property(self, "position", _rest_pos + kick, recoil_time * 0.3)
	_recoil_tween.tween_property(self, "position", _rest_pos, recoil_time * 0.7)
