extends RigidBody2D

@onready var blast_area: Area2D = $BlastArea
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var audio_rocketlaunch: AudioStreamPlayer = $Audio/Audio_ROCKETLAUNCH
@onready var audio_rocketexplode: AudioStreamPlayer = $Audio/Audio_ROCKETEXPLODE

var exploded := false
var bulletDamage := 30
var ownerOfBullet = null
var knockback_strength := 700.0
var knockback_up := 150.0
var camera = null

func _ready() -> void:
	if not audio_rocketlaunch.playing:
		audio_rocketlaunch.play()
	contact_monitor = true
	max_contacts_reported = 1

func _process(_delta: float) -> void:
	if not camera:
		camera = get_tree().get_first_node_in_group("Camera")

func _on_body_entered(body: Node) -> void:
	if exploded:
		return

	if body == ownerOfBullet:
		return

	if body.is_in_group("Bullets"):
		return

	explode()

func explode() -> void:
	if exploded:
		return
		
	collision_shape_2d.set_deferred("disabled", true)
	
	if not audio_rocketexplode.playing:
		audio_rocketexplode.play()

	exploded = true

	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sprite_2d.visible = false

	if camera:
		camera.start_camera_shake(1000)

	var bodies_inside := blast_area.get_overlapping_bodies()
	for body in bodies_inside:
		if body == ownerOfBullet:
			continue

		_apply_knockback(body)

		if body.is_in_group("Player") or body.is_in_group("Enemy"):
			if body.has_method("bullet_hit"):
				body.bullet_hit(bulletDamage)

	var areas_inside := blast_area.get_overlapping_areas()
	for area in areas_inside:
		if area == blast_area:
			continue

		_apply_knockback(area)

		if area.has_method("bullet_hit"):
			area.bullet_hit(bulletDamage)

	cpu_particles_2d.emitting = true
	animated_sprite_2d.play("hit")
	await get_tree().create_timer(cpu_particles_2d.lifetime).timeout
	await audio_rocketexplode.finished
	queue_free()

func _apply_knockback(body: Node2D) -> void:
	if body == null:
		return

	var dir := (body.global_position - global_position).normalized()
	var kb := dir * knockback_strength
	kb.y -= knockback_up

	if body is CharacterBody2D:
		var cb := body as CharacterBody2D
		cb.velocity += kb
		return

	if body is RigidBody2D:
		var rb := body as RigidBody2D
		rb.apply_impulse(kb, rb.global_position - global_position)
		return
