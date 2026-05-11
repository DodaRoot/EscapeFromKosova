extends Node2D

@onready var sprite: Sprite2D = $Bullet
@onready var blast_radius: CollisionShape2D = $BlastArea/BlastRadius
@onready var blast_area: Area2D = $BlastArea
@onready var area_2d: Area2D = $Area2D
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Audio
@onready var audio_rocketlaunch: AudioStreamPlayer = $Audio/Audio_ROCKETLAUNCH
@onready var audio_rocketexplode: AudioStreamPlayer = $Audio/Audio_ROCKETEXPLODE

var speed := 1000
var stopped := false
var ownerOfBullet
var bulletDamage
var camera
var knockback_strength := 800.0
var knockback_up := 100.0

func _ready() -> void:
	if not audio_rocketlaunch.playing:
		audio_rocketlaunch.play()

func _process(delta: float) -> void:
	if not stopped:
		position += transform.x * speed * delta
	if not camera:
		camera = get_tree().get_first_node_in_group("Camera")

func handle_hit() -> void:
	if stopped:
		return

	stopped = true
	
	area_2d.queue_free()
	sprite.queue_free()
	
	if camera:
		camera.start_camera_shake(1000)
	
	cpu_particles_2d.emitting = true
	animated_sprite_2d.play("hit")
	if not audio_rocketexplode.playing:
		if audio_rocketlaunch.playing:
			audio_rocketlaunch.stop()
		audio_rocketexplode.play()
		await audio_rocketexplode.finished
	
	await get_tree().create_timer(cpu_particles_2d.lifetime).timeout
	queue_free()

func _on_area_2d_body_shape_entered(_rid: RID, body: Node2D, _body_shape: int, _local_shape: int) -> void:
	if body.is_in_group("Bullets"):
		return

	if body.is_in_group("WorldItems"):
		return
		
	if body == ownerOfBullet:
		return
		
	var bodies_inside_aoe = blast_area.get_overlapping_bodies()
	for entity in bodies_inside_aoe:
		_apply_knockback(entity)
		if entity.is_in_group("Player") or entity.is_in_group("Enemy") or entity.is_in_group("Objects"):
			if entity.health and entity.health > 0 and entity != ownerOfBullet:
				if entity.has_method("bullet_hit"):
					entity.bullet_hit(bulletDamage)
					
	handle_hit()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Bullets"):
		return

	if area.is_in_group("WorldItems"):
		return

	if area == blast_area:
		return

	if area.has_method("bullet_hit"):
		area.bullet_hit(bulletDamage)

	_apply_knockback(area)
	handle_hit()

func _apply_knockback(body: Node2D) -> void:
	if body == null:
		return

	var dir := transform.x.normalized()
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

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
