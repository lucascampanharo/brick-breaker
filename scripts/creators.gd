extends Control


const TITLE_TEXT := "Criadores"

const MEMBER_NAMES := [
	"Elinéia Rita Bassani",
	"Lucas Ferreira Gritti Campanharo",
	"Luís Miguel Jacobus",
	"Sanny Belisário",
]

const COLOR_TITLE := Color("76ABAE")
const COLOR_BUTTON_NORMAL := Color("303841")
const COLOR_BUTTON_HOVER := Color("596067")
const COLOR_BUTTON_PRESSED := Color("533483")
const COLOR_BUTTON_TEXT := Color("76ABAE")

const BACK_ICON := preload("res://assets/icons/back.svg")

const REFERENCE_SIZE := Vector2(1080.0, 1920.0)

var ui_scale := 1.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var viewport_size := get_viewport_rect().size

	var scale_x := viewport_size.x / REFERENCE_SIZE.x
	var scale_y := viewport_size.y / REFERENCE_SIZE.y

	ui_scale = min(scale_x, scale_y)

	_build_content()


func _build_content() -> void:
	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)

	margin.add_theme_constant_override(
		"margin_left",
		int(32 * ui_scale)
	)
	margin.add_theme_constant_override(
		"margin_top",
		int(30 * ui_scale)
	)
	margin.add_theme_constant_override(
		"margin_right",
		int(32 * ui_scale)
	)
	margin.add_theme_constant_override(
		"margin_bottom",
		int(24 * ui_scale)
	)

	add_child(margin)

	var layout := VBoxContainer.new()
	layout.name = "Layout"
	layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override("separation", 0)

	margin.add_child(layout)

	var top_spacer := Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL

	layout.add_child(top_spacer)

	var title := Label.new()
	title.name = "Title"
	title.text = TITLE_TEXT
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	title.add_theme_font_size_override(
		"font_size",
		int(64 * ui_scale)
	)
	title.add_theme_color_override(
		"font_color",
		COLOR_TITLE
	)

	layout.add_child(title)

	var title_gap := Control.new()
	title_gap.custom_minimum_size = Vector2(
		0,
		35 * ui_scale
	)

	layout.add_child(title_gap)

	var members_center := CenterContainer.new()
	members_center.name = "MembersCenter"
	members_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	members_center.size_flags_vertical = Control.SIZE_EXPAND_FILL

	layout.add_child(members_center)

	var members := VBoxContainer.new()
	members.name = "Members"
	members.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var viewport_width := get_viewport_rect().size.x

	members.custom_minimum_size = Vector2(
		viewport_width * 0.60,
		0
	)

	members.add_theme_constant_override(
		"separation",
		int(32 * ui_scale)
	)

	members_center.add_child(members)

	for member_name in MEMBER_NAMES:
		members.add_child(
			_build_member_button(member_name)
		)

	var bottom_spacer := Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bottom_spacer.custom_minimum_size = Vector2(
		0,
		10 * ui_scale
	)

	layout.add_child(bottom_spacer)

	var footer := HBoxContainer.new()
	footer.name = "Footer"
	footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.alignment = BoxContainer.ALIGNMENT_BEGIN

	footer.add_theme_constant_override(
		"separation",
		0
	)

	layout.add_child(footer)

	footer.add_child(
		_build_back_button()
	)


func _build_member_button(text_value: String) -> Button:
	var button := Button.new()

	button.text = text_value

	button.custom_minimum_size = Vector2(
		0,
		145 * ui_scale
	)

	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.autowrap_mode = TextServer.AUTOWRAP_WORD

	button.add_theme_font_size_override(
		"font_size",
		int(48 * ui_scale)
	)

	button.add_theme_color_override(
		"font_color",
		COLOR_BUTTON_TEXT
	)
	button.add_theme_color_override(
		"font_hover_color",
		COLOR_BUTTON_TEXT
	)
	button.add_theme_color_override(
		"font_pressed_color",
		COLOR_BUTTON_TEXT
	)

	button.add_theme_stylebox_override(
		"normal",
		_make_button_style(COLOR_BUTTON_NORMAL)
	)
	button.add_theme_stylebox_override(
		"hover",
		_make_button_style(COLOR_BUTTON_HOVER)
	)
	button.add_theme_stylebox_override(
		"pressed",
		_make_button_style(COLOR_BUTTON_PRESSED)
	)

	return button


func _build_back_button() -> TextureButton:
	var button := TextureButton.new()
	button.name = "Back"

	var button_size: float = clampf(
		get_viewport_rect().size.x * 0.10,
		32.0,
		52.0
	)

	button.custom_minimum_size = Vector2(
		button_size,
		button_size
	)

	button.texture_normal = BACK_ICON
	button.texture_hover = BACK_ICON
	button.texture_pressed = BACK_ICON

	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

	button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	button.modulate = Color(1, 1, 1, 1)

	button.mouse_entered.connect(
		func():
			button.modulate = Color(1, 1, 1, 0.85)
	)

	button.mouse_exited.connect(
		func():
			button.modulate = Color(1, 1, 1, 1)
	)

	button.button_down.connect(
		func():
			button.modulate = Color(1, 1, 1, 0.7)
	)

	button.button_up.connect(
		func():
			button.modulate = Color(1, 1, 1, 0.85)
	)

	button.pressed.connect(_on_back_pressed)

	return button


func _make_button_style(base_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()

	style.bg_color = base_color

	var radius := int(
		30 * ui_scale
	)

	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius

	return style

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
