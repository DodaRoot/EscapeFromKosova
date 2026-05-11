extends CharacterBody2D

# Nodes
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var skel: Skeleton2D = $Skeleton2D
@onready var gun_spawn: Node2D = $Skeleton2D/Hip/Torso/UpperLeftArm/LowerLeftArm/LeftHand/GunPoint/GunSpawn
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var health_bar: TextureProgressBar = $Skeleton2D/Hip/HealthBar

# Audio
@onready var audio_enemydie: AudioStreamPlayer = $Audio/Audio_ENEMYDIE
@onready var audio_enemydie_2: AudioStreamPlayer = $Audio/Audio_ENEMYDIE2

const GLOCK := preload("res://Scenes/Guns/glock.tscn")

# Tuning
@export var AGRO_DIST := 1500.0
@export var StaticMovment := false
const MIN_DIST := 500.0
const PUSH := 100.0

var speed := 500.0
var dir := 1
var patrol_timer := 3.0
var ai_timer := 0.0

var fire_mode := false
var dead := false
var aggression := false

var init_skel_scale_x := 1.0
var player_target: CharacterBody2D = null

@export var health = 100
@export var selected_weapon: PackedScene = GLOCK


func _ready() -> void:
	health_bar.max_value = health
	init_skel_scale_x = skel.scale.x
	_set_active(false)
	_spawn_weapon(selected_weapon)

func _physics_process(delta: float) -> void:
	if dead:
		return
	
	if health <= 0:
		_die()
		return
		
	skel.visible = true
	patrol_timer -= delta
	_update_health_bar_flip()
	_apply_gravity(delta)
	
	ai_timer -= delta
	if ai_timer <= 0:
		_handle_ai()
		ai_timer = 0.15

	if not StaticMovment:
		_handle_movement()
	_push_rigid_bodies()
	move_and_slide()


# --- Movement / Physics ---
func _apply_gravity(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta

		if !animation_tree.get("parameters/PlayJump/active"):
			animation_tree.set("parameters/PlayJump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	else:
		if animation_tree.get("parameters/PlayJump/active"):
			animation_tree.set("parameters/PlayJump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)


func _handle_movement() -> void:
	var dist_sq
	if !is_instance_valid(player_target):
		player_target = _get_player_target()
		
	if player_target:
		dist_sq = global_position.distance_squared_to(player_target.global_position)

	if dir != 0 and dist_sq > MIN_DIST * MIN_DIST:
		velocity.x = dir * speed

		if is_on_floor():
			animation_tree.set("parameters/Move/blend_amount", 1)

			var walk_scale := 1.5 if skel.scale.x == dir else -1.5
			animation_tree.set("parameters/WalkTime/scale", walk_scale)

			if !fire_mode:
				skel.scale.x = init_skel_scale_x * dir
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)

		if is_on_floor():
			animation_tree.set("parameters/Move/blend_amount", 0)


# --- AI ---
func _handle_ai() -> void:
	if !is_instance_valid(player_target):
		player_target = _get_player_target()

	if player_target:
		var dist_sq := global_position.distance_squared_to(player_target.global_position)

		if dist_sq < AGRO_DIST * AGRO_DIST:
			_enter_aggression()
			_update_direction_to_player()
			return

	_exit_aggression()
	_patrol()


func _enter_aggression() -> void:
	if aggression:
		return
	aggression = true
	if !animation_tree.get("parameters/PlayAgression/active"):
		animation_tree.set("parameters/PlayAgression/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _exit_aggression() -> void:
	aggression = false


func _patrol() -> void:
	if patrol_timer > 0.0:
		return

	dir *= -1
	patrol_timer = 3.0


func _update_direction_to_player() -> void:
	var dx := player_target.global_position.x - global_position.x
	dir = sign(dx)


# --- Death ---
func _die() -> void:
	dead = true
	animation_tree.set("parameters/PlayDeath/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	if not audio_enemydie.playing and not audio_enemydie_2.playing:
		if randf() > 0.5:
			audio_enemydie.play()
			await audio_enemydie.finished
		else:
			audio_enemydie_2.play()
			await audio_enemydie_2.finished
	_die_delayed()
	
	for child in gun_spawn.get_children():
		child.set_process(false)
		child.set_physics_process(false)


func _die_delayed() -> void:
	await get_tree().create_timer(0.3).timeout
	Global.enemies_killed_level += 1
	Global.enemies_killed_total += 1
	queue_free()

func bullet_hit(damage: int) -> void:
	health -= damage
	health_bar.value = health

	if !health_bar.visible:
		health_bar.visible = true

	if health <= 0:
		_die()

	animation_tree.set("parameters/PlayHit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _spawn_weapon(scene: PackedScene) -> void:
	var gun = scene.instantiate()
	gun_spawn.add_child(gun)

func _update_health_bar_flip() -> void:
	health_bar.scale.x = skel.scale.x

func _get_player_target() -> CharacterBody2D:
	var players := get_tree().get_nodes_in_group("Player")
	return players[0] if !players.is_empty() else null

func _push_rigid_bodies() -> void:
	var count := get_slide_collision_count()
	for i in count:
		var c := get_slide_collision(i)
		var body := c.get_collider()
		if body is RigidBody2D:
			body.apply_central_impulse(-c.get_normal() * PUSH)


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	_set_active(true)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	_set_active(false)

func _set_active(active: bool) -> void:
	if position.y < 0:
		set_physics_process(active)

		skel.visible = active

		if has_node("CollisionShape2D"):
			$CollisionShape2D.disabled = not active

		animation_tree.active = active
		anim.playback_active = active
