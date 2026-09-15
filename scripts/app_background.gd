extends CanvasLayer

const WALLPAPER_PATH := "res://assets/wallpaper.png"
const COLOR_OVERLAY := Color("7D7D7D")
const OVERLAY_OPACITY := 0.1

func _ready() -> void:
	layer = -100
	follow_viewport_enabled = false

	var wallpaper := TextureRect.new()
	wallpaper.name = "Wallpaper"
	wallpaper.texture = load(WALLPAPER_PATH)
	wallpaper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	wallpaper.stretch_mode = TextureRect.STRETCH_SCALE
	wallpaper.set_anchors_preset(Control.PRESET_FULL_RECT)
	wallpaper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wallpaper)

	var overlay := ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(COLOR_OVERLAY, OVERLAY_OPACITY)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
