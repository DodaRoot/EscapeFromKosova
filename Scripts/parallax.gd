extends CanvasLayer

@onready var static_background: TextureRect = $StaticBackground
@onready var mountains_parallax: Parallax2D = $MountainsParallax
@onready var mountains: TextureRect = $MountainsParallax/Mountains
@onready var ground_parallax: Parallax2D = $GroundParallax
@onready var ground: TextureRect = $GroundParallax/Ground
@onready var clouds_parallax: Parallax2D = $Clouds
@onready var clouds: TextureRect = $Clouds/Clouds
@onready var city: TextureRect = get_node_or_null("CityParallax/City")

func _ready() -> void:
	get_viewport().size_changed.connect(_resize_layers)
	_resize_layers()

func _resize_layers() -> void:
	var vp_width: float = get_viewport().get_visible_rect().size.x

	static_background.size.x = vp_width

	mountains.size.x = vp_width
	mountains_parallax.repeat_size.x = mountains.size.x  # match the rect, not the viewport directly

	ground.size.x = vp_width
	ground_parallax.repeat_size.x = ground.size.x

	clouds.size.x = vp_width
	clouds_parallax.repeat_size.x = clouds.size.x

	if city != null:
		city.size.x = vp_width
