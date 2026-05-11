extends Area2D

@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var mine_texture: Sprite2D = $MineTexture
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_explosion: AudioStreamPlayer = $Audio_EXPLOSION

var camera
var knockback_strength := 10.0
var knockback_up := 450.0

func _process(_delta: float) -> void:
	if not camera:
		camera = get_tree().get_first_node_in_group("Camera")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.is_in_group("Enemy"):
		if body.has_method("bullet_hit"):
			body.bullet_hit(50)
	
	mine_texture.queue_free()
	collision_shape_2d.queue_free()
	cpu_particles_2d.emitting = true
	_apply_knockback(body)
	
	if camera:
		camera.start_camera_shake(1000)
	
	if not audio_explosion.playing:
		audio_explosion.play()
		await audio_explosion.finished
		
	await get_tree().create_timer(cpu_particles_2d.lifetime).timeout
	queue_free()

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
