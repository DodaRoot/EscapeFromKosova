extends RigidBody2D

@export var health = 10
@export var killable = false

func _process(_delta: float) -> void:
	if health <= 0 and killable:
		queue_free()

func bullet_hit(damage: int) -> void:
	health -= damage
