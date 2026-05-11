extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.is_in_group("Enemy"):
		if body.has_method("bullet_hit"):
			body.bullet_hit(20)
		if body.has_method("knockback"):
			body.knockback(-200)
