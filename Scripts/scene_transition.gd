extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_transition: AudioStreamPlayer = $Audio_Transition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func change_scene(target):
	if not audio_transition.playing:
		audio_transition.play()
	animation_player.play("fade_in")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target)
	animation_player.play("fade_out")
