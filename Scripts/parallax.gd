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
	static_background.size.x = get_viewport().size.x
	mountains_parallax.repeat_size.x = get_viewport().size.x
	mountains.size.x = get_viewport().size.x
	ground_parallax.repeat_size.x = get_viewport().size.x
	ground.size.x = get_viewport().size.x
	clouds_parallax.repeat_size.x = get_viewport().size.x
	clouds.size.x = get_viewport().size.x
	
	if city != null:
		city.size.x = get_viewport().size.x
