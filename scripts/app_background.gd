extends CanvasLayer

var wallpaper: TextureRect

func _ready() -> void:
	layer = -100
	follow_viewport_enabled = false
	wallpaper = TextureRect.new()
	wallpaper.name = "Wallpaper"
	wallpaper.texture = preload("res://assets/wallpaper.png")
	wallpaper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	wallpaper.stretch_mode = TextureRect.STRETCH_SCALE
	wallpaper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wallpaper)
	get_viewport().size_changed.connect(_layout)
	_layout()

func _layout() -> void:
	# The reference artwork extends past the display's right edge.
	var viewport_size := get_viewport().get_visible_rect().size
	wallpaper.position.x = -viewport_size.x * 0.05
	wallpaper.size = viewport_size * Vector2(1.2, 1.0)
