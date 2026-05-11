extends CharacterBody2D

@onready var sprite: Sprite2D = $Helicopter
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var muzzle: Marker2D = $Muzzle
@onready var health_bar: TextureProgressBar = $HealthBar

@export var health := 100
@export var AGRO_DIST := 1500.0
@export var SPEED := 400.0
@export var PATROL_DISTANCE := 700.0
@export var FLOAT_AMOUNT := 20.0
@export var FLOAT_SPEED := 2.0

@export var ATTACK_HEIGHT := 700.0
@export var ARRIVE_X_RANGE := 20.0
@export var ARRIVE_Y_RANGE := 12.0
@export var ATTACK_PAUSE := 0.3
@export var PATROL_AFTER_ATTACK := 3.0

@export var DEATH_FALL_SPEED := 500.0
@export var DEATH_SPIN_SPEED := 8.0

@onready var audio_idle_fly: AudioStreamPlayer = $Audio_IdleFly

enum State { PATROL, ATTACK, HOVER }
const ROCKET = preload("res://Scenes/Objects/bullets/heli_rocket.tscn")

var state: State = State.PATROL
var start_position := Vector2.ZERO
var attack_target := Vector2.ZERO
var player_target: CharacterBody2D = null

var dir := 1
var time_passed := 0.0
var state_timer := 0.0
var dead := false

func _ready() -> void:
	health_bar.max_value = health
	health_bar.value = health
	start_position = global_position

func _physics_process(delta: float) -> void:
	if dead:
		_death_drop(delta)
		return

	time_passed += delta
	player_target = _get_player_target()

	_update_state(delta)
	_update_movement()
	move_and_slide()

	if health <= 0:
		_die()

func _update_state(delta: float) -> void:
	if state_timer > 0.0:
		state_timer -= delta

	match state:
		State.PATROL:
			if _player_in_range() and state_timer <= 0.0:
				_set_attack_target()
				state = State.ATTACK

		State.ATTACK:
			if !_player_in_range():
				state = State.PATROL
				return

			_set_attack_target()

			if _reached_attack_target():
				drop_rocket()
				state = State.HOVER
				state_timer = ATTACK_PAUSE

		State.HOVER:
			if !_player_in_range():
				state = State.PATROL
				return

			if state_timer <= 0.0:
				state = State.PATROL
				state_timer = PATROL_AFTER_ATTACK

func _update_movement() -> void:
	var float_y := sin(time_passed * FLOAT_SPEED) * FLOAT_AMOUNT

	match state:
		State.ATTACK:
			var to_target := attack_target - global_position

			velocity.x = 0.0 if abs(to_target.x) <= ARRIVE_X_RANGE else sign(to_target.x) * SPEED
			velocity.y = 0.0 if abs(to_target.y) <= ARRIVE_Y_RANGE else sign(to_target.y) * SPEED

			if velocity.x != 0.0:
				dir = int(sign(velocity.x))

		State.HOVER:
			velocity.x = 0.0
			velocity.y = float_y * 0.15

		State.PATROL:
			if global_position.x >= start_position.x + PATROL_DISTANCE:
				dir = -1
			elif global_position.x <= start_position.x - PATROL_DISTANCE:
				dir = 1

			velocity.x = dir * SPEED
			velocity.y = float_y

	sprite.flip_h = dir > 0

func _death_drop(delta: float) -> void:
	collision_shape_2d.disabled = true
	velocity.x = 0.0
	velocity.y = DEATH_FALL_SPEED
	rotation += DEATH_SPIN_SPEED * delta
	move_and_slide()

	if global_position.y > 300.0:
		queue_free()

func _set_attack_target() -> void:
	if player_target == null:
		return

	attack_target = Vector2(
		player_target.global_position.x,
		player_target.global_position.y - ATTACK_HEIGHT
	)

func _player_in_range() -> bool:
	return player_target != null and global_position.distance_to(player_target.global_position) <= AGRO_DIST

func _reached_attack_target() -> bool:
	return (
		abs(global_position.x - attack_target.x) <= ARRIVE_X_RANGE
		and abs(global_position.y - attack_target.y) <= ARRIVE_Y_RANGE
	)

func _get_player_target() -> CharacterBody2D:
	var players := get_tree().get_nodes_in_group("Player")
	return players[0] as CharacterBody2D if !players.is_empty() else null

func bullet_hit(damage: int) -> void:
	health -= damage
	health_bar.value = health

	if !health_bar.visible:
		health_bar.visible = true

func _die() -> void:
	dead = true
	health_bar.visible = false
	Global.enemies_killed_level += 1
	Global.enemies_killed_total += 1

func drop_rocket():
	var rocket = ROCKET.instantiate()
	rocket.global_position = muzzle.global_position
	rocket.ownerOfBullet = self
	get_tree().current_scene.add_child(rocket)


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if not audio_idle_fly.playing:
		audio_idle_fly.play()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if audio_idle_fly.playing:
		audio_idle_fly.stop()
