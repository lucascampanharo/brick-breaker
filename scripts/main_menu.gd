extends Control

const TITLE_TEXT := "Brick Breaker"
const MENU_OPTIONS := ["Iniciar", "Configurações", "Criadores"]
const LEVEL_1_SCENE_PATH := "res://scenes/level_1.tscn"

const COLOR_TITLE := Color("76ABAE")
const COLOR_BUTTON_NORMAL := Color("303841")
const COLOR_BUTTON_HOVER := Color("596067")
const COLOR_BUTTON_PRESSED := Color("533483")
const COLOR_BUTTON_TEXT := Color("76ABAE")


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_content()


func _build_content() -> void:
	var layout := VBoxContainer.new()
	layout.name = "Layout"
	layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override("separation", 0)
	add_child(layout)

	var title_spacer_top := Control.new()
	title_spacer_top.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(title_spacer_top)

	layout.add_child(_build_title())

	var middle_spacer := Control.new()
	middle_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle_spacer.custom_minimum_size = Vector2(0, 40)
	layout.add_child(middle_spacer)

	layout.add_child(_build_menu_buttons())

	var bottom_spacer := Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bottom_spacer.custom_minimum_size = Vector2(0, 0)
	layout.add_child(bottom_spacer)
	bottom_spacer.size_flags_stretch_ratio = 2.0


func _build_title() -> Label:
	var title := Label.new()
	title.name = "Title"
	title.text = TITLE_TEXT
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", COLOR_TITLE)
	return title


func _build_menu_buttons() -> VBoxContainer:
	var container := VBoxContainer.new()
	container.name = "MenuButtons"
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_theme_constant_override("separation", 24)
	container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var callbacks := [_on_start_pressed, _on_settings_pressed, _on_creators_pressed]
	for i in MENU_OPTIONS.size():
		container.add_child(_build_menu_button(MENU_OPTIONS[i], callbacks[i]))

	return container


func _build_menu_button(label_text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(320, 80)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 32)
	button.add_theme_color_override("font_color", COLOR_BUTTON_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_BUTTON_TEXT)
	button.add_theme_color_override("font_pressed_color", COLOR_BUTTON_TEXT)

	button.add_theme_stylebox_override("normal", _make_button_style(COLOR_BUTTON_NORMAL))
	button.add_theme_stylebox_override("hover", _make_button_style(COLOR_BUTTON_HOVER))
	button.add_theme_stylebox_override("pressed", _make_button_style(COLOR_BUTTON_PRESSED))

	button.pressed.connect(callback)
	return button


func _make_button_style(base_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = base_color
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	return style


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(LEVEL_1_SCENE_PATH)


func _on_settings_pressed() -> void:
	print("Configurações pressionado")


func _on_creators_pressed() -> void:
	print("Criadores pressionado")
