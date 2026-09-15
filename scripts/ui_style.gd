extends RefCounted

const TEXT := Color("76ABAE")
const PANEL := Color("303841")
const SELECTED := Color("F15A3A")
const BACK_ICON := preload("res://assets/icons/back.svg")
const BOLD := preload("res://assets/ui_bold.tres")

static func box(color: Color, radius: int, padding: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	return style

static func label(text: String, font_size: int = 34, color: Color = TEXT) -> Label:
	var result := Label.new()
	result.text = text
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result.add_theme_font_override("font", BOLD)
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result

static func button(text: String, callback: Callable, pill: bool = false) -> Button:
	var result := Button.new()
	result.text = text
	result.focus_mode = Control.FOCUS_NONE
	result.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	result.add_theme_font_override("font", ThemeDB.fallback_font if pill else BOLD)
	result.add_theme_font_size_override("font_size", 24 if pill else 36)
	for state in ["font_color", "font_hover_color", "font_pressed_color"]:
		result.add_theme_color_override(state, Color.WHITE if pill else TEXT)
	result.add_theme_stylebox_override("normal", box(TEXT if pill else PANEL, 14 if pill else 44))
	result.add_theme_stylebox_override("hover", box(Color("659699") if pill else Color("3B4751"), 14 if pill else 44))
	result.add_theme_stylebox_override("pressed", box(Color("4C7F82") if pill else Color("465560"), 14 if pill else 44))
	result.pressed.connect(callback)
	return result

static func back(callback: Callable) -> TextureButton:
	var result := TextureButton.new()
	result.name = "BackButton"
	result.texture_normal = BACK_ICON
	result.texture_hover = BACK_ICON
	result.texture_pressed = BACK_ICON
	result.ignore_texture_size = true
	result.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	result.focus_mode = Control.FOCUS_NONE
	result.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	result.pressed.connect(callback)
	return result

# Coordinates refer to the display only, without the phone frame.
static func place(control: Control, rect: Rect2, viewport: Vector2) -> void:
	var ratio := viewport / Vector2(720, 1560)
	control.position = rect.position * ratio
	control.size = rect.size * ratio

static func place_back(control: Control, viewport: Vector2) -> void:
	control.position = Vector2(44, viewport.y - 108)
	control.size = Vector2(64, 64)
