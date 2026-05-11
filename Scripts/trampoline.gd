extends StaticBody2D

var bounce_force = -2000
@onready var audio_bounce: AudioStreamPlayer = $Audio/Audio_BOUNCE

func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	pass

func _on_bounce_area_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		body.linear_velocity.y = bounce_force
		if not audio_bounce.playing:
			audio_bounce.play()
	
	if body is CharacterBody2D:
		body.velocity.y = bounce_force
		if not audio_bounce.playing:
			audio_bounce.play()
