extends RigidBody2D

const ROCKET = preload("res://Scenes/Objects/bullets/heli_rocket.tscn")

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var muzzle: Marker2D

var speed := 1500.0
var time_to_drop = 0.5
var drop_time
var on_screen = false
var destroyed := false

func _ready() -> void:
	visible = false
	drop_time = time_to_drop
	collision_shape_2d.disabled = true
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if on_screen and not destroyed:
		drop_time -= delta
		if drop_time <= 0:
			drop_rocket()
			drop_time = time_to_drop

func drop_rocket():
	if destroyed:
		return
		
	var rocket = ROCKET.instantiate()
	rocket.global_position = muzzle.global_position
	rocket.ownerOfBullet = self
	get_tree().current_scene.add_child(rocket)

func start_plane():
	visible = true
	linear_velocity = Vector2(speed, 0)

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	on_screen = true
	collision_shape_2d.disabled = false

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if on_screen:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		start_plane()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Bullets"):
		return
	
	if destroyed:
		return
	
	destroyed = true
	
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	collision_shape_2d.disabled = true
	
	visible = false
	
	queue_free()
