extends CharacterBody2D

@export var AGRO_DIST := 1500.0
@export var health := 100
@export var StaticMovment = false
@export var show_boss := false

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var boss: Node2D = $Boss
@onready var audio_tank_idle: AudioStreamPlayer = $Audio/Audio_TankIdle

const SPEED := 300.0
const MIN_DIST := 1200.0
const PUSH := 100.0

var player_target: CharacterBody2D = null
var dir := 1
var init_tank_scale := 1.0
var dead := false
var aggression := false
var patrol_timer := 3.0
var ai_timer := 0.0
var fire_mode := false
var rocket_mag = 10
var rocket_bullets
var default_health_bar_scale = 0
var facing = 0

func _ready() -> void:
	default_health_bar_scale = health_bar.scale.x
	health_bar.max_value = health
	health_bar.value = health
	if show_boss:
		boss.visible = true
	init_tank_scale = scale.x

func _physics_process(delta: float) -> void:
	if dead:
		return

	if health <= 0:
		_die()
		return

	patrol_timer -= delta

	if !is_on_floor():
		velocity += get_gravity() * 2 * delta

	ai_timer -= delta
	if ai_timer <= 0.0:
		_handle_ai()
		ai_timer = 0.15
	if not StaticMovment:
		_handle_movement(delta)
	move_and_slide()
	_update_health_bar_flip()
	_push_rigid_bodies()

func _handle_movement(_delta: float) -> void:
	if !is_instance_valid(player_target):
		player_target = _get_player_target()

	var dist_sq := INF
	if player_target:
		dist_sq = global_position.distance_squared_to(player_target.global_position)

	if dir != 0 and dist_sq > MIN_DIST * MIN_DIST:
		velocity.x = dir * SPEED
		if is_on_floor() and !fire_mode:
			if velocity.x > 0:
				transform.x = Vector2(-1.0, 0.0)
				facing = -1
			elif velocity.x < 0:
				transform.x = Vector2(1.0, 0.0)
				facing = 1
	else:
		velocity.x = 0.0

func _get_player_target() -> CharacterBody2D:
	var players := get_tree().get_nodes_in_group("Player")
	return players[0] if !players.is_empty() else null

func _handle_ai() -> void:
	if !is_instance_valid(player_target):
		player_target = _get_player_target()

	if player_target:
		var dist_sq := global_position.distance_squared_to(player_target.global_position)
		if dist_sq < AGRO_DIST * AGRO_DIST:
			aggression = true
			_update_direction_to_player()
			return

	aggression = false
	_patrol()

func _patrol() -> void:
	if patrol_timer > 0.0:
		return

	dir *= -1
	patrol_timer = 3.0

func _update_direction_to_player() -> void:
	var dx := player_target.global_position.x - global_position.x
	dir = sign(dx)
	if dir == 0:
		dir = 1

func _push_rigid_bodies() -> void:
	var count := get_slide_collision_count()
	for i in range(count):
		var c := get_slide_collision(i)
		var body := c.get_collider()
		if body is RigidBody2D:
			body.apply_central_impulse(-c.get_normal() * PUSH)

func bullet_hit(damage: int) -> void:
	health -= damage
	health_bar.value = health

	if !health_bar.visible:
		health_bar.visible = true

	if health <= 0:
		_die()

func _die() -> void:
	dead = true
	health_bar.visible = false
	_die_delayed()

func _die_delayed() -> void:
	await get_tree().create_timer(0.3).timeout
	Global.enemies_killed_level += 1
	Global.enemies_killed_total += 1
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if not audio_tank_idle.playing:
		audio_tank_idle.play()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if audio_tank_idle.playing:
		audio_tank_idle.stop()

func _update_health_bar_flip() -> void:
	if facing != 0:
		health_bar.scale.x = default_health_bar_scale * facing
