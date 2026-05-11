extends Node2D

@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var sprite: Sprite2D = $Bullet
@onready var area_2d: Area2D = $Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var speed := 1000
var stopped := false
var ownerOfBullet
var bulletDamage
var knockback_strength := 500.0
var knockback_up := 100.0

# Audio
@onready var audio_bullethitground: AudioStreamPlayer = $Audio/Audio_BULLETHITGROUND
@onready var audio_bullethitflesh: AudioStreamPlayer = $Audio/Audio_BULLETHITFLESH

func _process(delta: float) -> void:
	if is_instance_valid(ownerOfBullet) and ownerOfBullet.is_in_group("Enemy") and ownerOfBullet.dead:
		queue_free()
	if not stopped:
		position += transform.x * speed * delta

func handle_hit(object_hit) -> void:
	if stopped:
		return

	stopped = true
	
	area_2d.queue_free()
	sprite.queue_free()
	
	if object_hit:
		animated_sprite_2d.play("hit")
		cpu_particles_2d.initial_velocity_max = 250
		cpu_particles_2d.color = Color("8d4600ff")
		cpu_particles_2d.emitting = true

		if not audio_bullethitground.playing:
			audio_bullethitground.play()
			await audio_bullethitground.finished
	else:
		animated_sprite_2d.play("blood")
		cpu_particles_2d.color = Color("ff0a06ff")
		cpu_particles_2d.emitting = true
		if not audio_bullethitflesh.playing:
			audio_bullethitflesh.play()
			await audio_bullethitflesh.finished
	
	await get_tree().create_timer(cpu_particles_2d.lifetime).timeout
	queue_free()

func _on_area_2d_body_shape_entered(_rid: RID, body: Node2D, _body_shape: int, _local_shape: int) -> void:
	if body.is_in_group("WorldItems"):
		return
		
	if body == ownerOfBullet:
		return
		
	if body.is_in_group("Player") or body.is_in_group("Enemy"):
		if body.health and body.health > 0:
			if body.has_method("bullet_hit"):
				body.bullet_hit(bulletDamage)
				handle_hit(false)
	else: 
		_apply_knockback(body) 
		handle_hit(true)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("WorldItems"):
		return
		
	handle_hit(true)
	
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
