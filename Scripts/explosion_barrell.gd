extends RigidBody2D

@onready var blast_area: Area2D = $BlastArea
@export var explosion_damage = 50
@onready var barrell: Sprite2D = $Barrell
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var audio_explosion: AudioStreamPlayer = $Audio_EXPLOSION
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var camera
var health = 10
var exploded = false
var knockback_strength := 800.0
var knockback_up := 100.0

func _process(_delta: float) -> void:
	if not camera:
		camera = get_tree().get_first_node_in_group("Camera")

func explode():
	barrell.queue_free()
	collision_shape_2d.set_deferred("disabled", true)
	var bodies_inside_aoe = blast_area.get_overlapping_bodies()
	
	for entity in bodies_inside_aoe:
		if entity == self:
			continue
		_apply_knockback(entity)
		if not entity == self and entity.is_in_group("Player") or entity.is_in_group("Enemy"):
			if entity.has_method("bullet_hit"):
				entity.bullet_hit(explosion_damage)

	if camera:
		camera.start_camera_shake(1000)
	
	cpu_particles_2d.emitting = true
	
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

func bullet_hit(_bulletDamage):
	health -= 10
	if health <= 0 and not exploded:
		exploded = true
		explode()
