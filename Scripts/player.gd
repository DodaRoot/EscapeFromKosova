extends CharacterBody2D

# Nodes
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var skel: Skeleton2D = $Skeleton2D
@onready var gun_spawn: Node2D = $Skeleton2D/Hip/Torso/UpperLeftArm/LowerLeftArm/LeftHand/GunPoint/GunSpawn
@onready var idle_head: TextureRect = $Skeleton2D/Hip/Torso/Head/IdleHead
@onready var shoot_head: TextureRect = $Skeleton2D/Hip/Torso/Head/ShootHead
@onready var animation_tree: AnimationTree = $AnimationTree

# Audio
@onready var audio_run: AudioStreamPlayer = $Audio/Audio_RUN
@onready var audio_jumpstart: AudioStreamPlayer = $Audio/Audio_JUMPSTART
@onready var audio_jumpstart_2: AudioStreamPlayer = $Audio/Audio_JUMPSTART2
@onready var audio_jumpstartwhoosh: AudioStreamPlayer = $Audio/Audio_JUMPSTARTWHOOSH
@onready var audio_jumplanding: AudioStreamPlayer = $Audio/Audio_JUMPLANDING
@onready var audio_hurt: AudioStreamPlayer = $Audio/Audio_HURT
@onready var audio_hurt_2: AudioStreamPlayer = $Audio/Audio_HURT2

# Guns
const AK := preload("res://Scenes/Guns/ak_47.tscn")
const GLOCK := preload("res://Scenes/Guns/glock.tscn")
const SNIPER := preload("res://Scenes/Guns/sniper.tscn")
const ROCKET_LAUNCHER := preload("res://Scenes/Guns/rocket_launcher.tscn")

# Tuning
const PUSH := 100.0
const GRAVITY_MULTIPLIER := 3.0

@export var jump_buffer_time := 0.1
@export var coyote_time := 0.1

# Faces (idle, shoot)
const FACES := {
	"HashishTaqi": [
		preload("res://Assets/Characters/Faces/PlayerFaces/HashishTaqi/HashishTaqi.png"),
		preload("res://Assets/Characters/Faces/PlayerFaces/HashishTaqi/HashishTaqiShoot.png")
	],
	"Rambo": [
		preload("res://Assets/Characters/Faces/PlayerFaces/Rambo/Rambo.png"),
		preload("res://Assets/Characters/Faces/PlayerFaces/Rambo/RamboShooting.png")
	],
	"MrBini": [
		preload("res://Assets/Characters/Faces/PlayerFaces/MrBini/MrBini.png"),
		preload("res://Assets/Characters/Faces/PlayerFaces/MrBini/MrBiniShooting.png")
	],
	"DrRugova": [
		preload("res://Assets/Characters/Faces/PlayerFaces/DrRugova/DrRugova.png"),
		preload("res://Assets/Characters/Faces/PlayerFaces/DrRugova/DrRugovaShoot.png")
	],
	"KomandantiLegjendar": [
		preload("res://Assets/Characters/Faces/PlayerFaces/KomandantiLegjendar/KomandantiLegjendar.png"),
		preload("res://Assets/Characters/Faces/PlayerFaces/KomandantiLegjendar/KomandantiLegjendarShooting.png")
	]
}

# Stats
var health := 100
var jump_vel := -1300.0
var speed := 1500.0

# Ammo
var ak_bullets := 30
var sniper_bullets := 10
var rocket_launcher_bullets := 3

var glock_mag := 7
var ak_mag := 30
var sniper_mag := 1
var rocket_mag := 1

# State
var fire_mode := false
var facing = 1
var input_dir := 0.0

var coyote_timer := 0.0
var jump_buffered := false
var jump_buffer_left := 0.0
var on_air := false

var selected_gun: PackedScene = GLOCK
var init_skel_scale_x := 1.0


func _ready() -> void:
	_apply_stats_from_skills()
	_load_face()

	init_skel_scale_x = skel.scale.x
	_spawn_gun(selected_gun)


func _physics_process(delta: float) -> void:
	if Global.player_is_dead:
		return

	_handle_jump(delta)
	_apply_gravity_and_jump_anim(delta)
	_handle_movement(delta)

	move_and_slide()
	_push_rigid_bodies()

	if health <= 0:
		Global.player_is_dead = true


func _apply_stats_from_skills() -> void:
	health = 100 + (Global.health_skill - 1) * 20
	jump_vel = -1300.0 + (Global.jump_skill - 1) * -50.0
	speed = 1500.0 + (Global.speed_skill - 1) * 50.0


# --- Jump ---
func _handle_jump(delta: float) -> void:
	if jump_buffer_left > 0.0:
		jump_buffer_left -= delta
		if jump_buffer_left <= 0.0:
			jump_buffered = false

	if Input.is_action_just_pressed("Jump"):
		if is_on_floor() or coyote_timer > 0.0:
			_jump()
		else:
			jump_buffered = true
			jump_buffer_left = jump_buffer_time


func _apply_gravity_and_jump_anim(delta: float) -> void:
	if !is_on_floor():
		if not on_air:
			on_air = true
		velocity += get_gravity() * delta * GRAVITY_MULTIPLIER
		coyote_timer = maxf(0.0, coyote_timer - delta)

		if !animation_tree.get("parameters/PlayJump/active"):
			animation_tree.set("parameters/PlayJump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		return
		
	# On floor
	coyote_timer = coyote_time

	if jump_buffered:
		_jump()

	if animation_tree.get("parameters/PlayJump/active"):
		animation_tree.set("parameters/PlayJump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	
	if on_air:
		on_air = false
		audio_jumplanding.play()

func _jump() -> void:
	if not audio_jumpstart.playing and not audio_jumpstart_2.playing and not audio_jumpstartwhoosh.playing:
		audio_jumpstartwhoosh.play()
		if randf() > 0.5:
			audio_jumpstart.play()
		else:
			audio_jumpstart_2.play()
	velocity.y = jump_vel
	jump_buffered = false
	jump_buffer_left = 0.0
	coyote_timer = 0.0
	await get_tree().create_timer(0.1).timeout

func _handle_movement(_delta: float) -> void:
	input_dir = Input.get_axis("MoveLeft", "MoveRight")
	input_dir = roundf(input_dir)

	if input_dir != 0.0:
		velocity.x = input_dir * speed

		if is_on_floor():
			animation_tree.set("parameters/Move/blend_amount", 1)

			var time_scale := 1.5 if skel.scale.x == input_dir else -1.5
			animation_tree.set("parameters/WalkTime/scale", time_scale)
			
			if not audio_run.playing:
				audio_run.play()
		else:
			if audio_run.playing:
				audio_run.stop()

		if !fire_mode and int(input_dir) != facing:
			facing = int(input_dir)
			skel.scale.x = init_skel_scale_x * facing
		return

	else:
		if audio_run.playing:
			audio_run.stop()

	velocity.x = move_toward(velocity.x, 0.0, speed)

	if is_on_floor() and !Global.player_is_dead:
		animation_tree.set("parameters/Move/blend_amount", 0)


func _push_rigid_bodies() -> void:
	var count := get_slide_collision_count()
	for i in count:
		var c := get_slide_collision(i)
		var body := c.get_collider()
		if body is RigidBody2D:
			body.apply_central_impulse(-c.get_normal() * PUSH)


# --- Face fire animation ---
func _load_face() -> void:
	if !FACES.has(Global.selected_character):
		return

	idle_head.texture = FACES[Global.selected_character][0]
	shoot_head.texture = FACES[Global.selected_character][1]

	if Global.selected_character == "KomandantiLegjendar":
		idle_head.position.x += 3
		shoot_head.position.x += 3


func play_fire_anim() -> void:
	idle_head.visible = false
	shoot_head.visible = true


func stop_fire_anim() -> void:
	idle_head.visible = true
	shoot_head.visible = false


# --- Weapons ---
func change_weapon(weapon: PackedScene) -> void:
	_clear_guns()
	_spawn_gun(weapon)


func _spawn_gun(scene: PackedScene) -> void:
	var gun = scene.instantiate()
	gun_spawn.add_child(gun)


func _clear_guns() -> void:
	for child in gun_spawn.get_children():
		child.queue_free()


# --- Damage ---
func bullet_hit(damage: int) -> void:
	if not audio_hurt.playing and not audio_hurt_2.playing:
		if randf() > 0.5:
			audio_hurt.play()
		else:
			audio_hurt_2.play()
	health -= damage
	animation_tree.set("parameters/PlayHit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func knockback(intensity: float) -> void:
	velocity.y = intensity
