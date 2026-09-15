extends Control

const UI := preload("res://scripts/ui_style.gd")
var pattern_grid: GridContainer
var color_grid: GridContainer
var title: Label
var pattern_panel: Panel
var color_panel: Panel
var pattern_title: Label
var subtitle: Label
var color_title: Label
var back_button: TextureButton

func _ready() -> void:
	title = UI.label("Configurações", 44)
	add_child(title)
	pattern_panel = _panel()
	color_panel = _panel()
	pattern_title = UI.label("Escolha o padrão de blocos:", 30)
	pattern_panel.add_child(pattern_title)
	subtitle = UI.label("(linhas x colunas)", 24)
	pattern_panel.add_child(subtitle)
	color_title = UI.label("Escolha o padrão de cores:", 30)
	color_panel.add_child(color_title)
	pattern_grid = GridContainer.new()
	pattern_grid.columns = 5
	pattern_panel.add_child(pattern_grid)
	for pattern in GameSettings.BLOCK_PATTERNS:
		var button := UI.button(pattern, _select_pattern.bind(pattern))
		button.add_theme_font_size_override("font_size", 30)
		pattern_grid.add_child(button)
	color_grid = GridContainer.new()
	color_grid.columns = 3
	color_panel.add_child(color_grid)
	for i in GameSettings.COLOR_PALETTES.size():
		var button := ColorPaletteButton.new()
		button.palette = GameSettings.COLOR_PALETTES[i]
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pressed.connect(_select_palette.bind(i))
		color_grid.add_child(button)
	back_button = UI.back(_on_back_pressed)
	add_child(back_button)
	_select_pattern(GameSettings.selected_pattern)
	_select_palette(GameSettings.selected_palette)
	resized.connect(_layout)
	_layout()

func _panel() -> Panel:
	var panel := Panel.new()
	panel.add_theme_stylebox_override("panel", UI.box(UI.PANEL, 32))
	add_child(panel)
	return panel

func _layout() -> void:
	UI.place(title, Rect2(0, 125, 720, 90), size)
	UI.place(pattern_panel, Rect2(100, 260, 520, 500), size)
	UI.place(color_panel, Rect2(100, 790, 520, 380), size)
	var scale_y := size.y / 1560.0
	pattern_title.position = Vector2(0, 20 * scale_y)
	pattern_title.size = Vector2(pattern_panel.size.x, 48 * scale_y)
	subtitle.position = Vector2(0, 64 * scale_y)
	subtitle.size = Vector2(pattern_panel.size.x, 32 * scale_y)
	color_title.position = Vector2(0, 25 * scale_y)
	color_title.size = Vector2(color_panel.size.x, 46 * scale_y)
	pattern_grid.position = Vector2(30, 110 * scale_y)
	color_grid.position = Vector2(30, 90 * scale_y)
	for grid in [pattern_grid, color_grid]:
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", int(12 * scale_y))
		for button in grid.get_children():
			button.custom_minimum_size = Vector2(84 if grid == pattern_grid else 146, 80 * scale_y)
		grid.size = Vector2.ZERO
	UI.place_back(back_button, size)

func _select_pattern(pattern: String) -> void:
	GameSettings.selected_pattern = pattern
	for button in pattern_grid.get_children():
		var style := UI.box(Color("D9D9D9"), 12)
		if button.text == pattern:
			style.set_border_width_all(4)
			style.border_color = UI.SELECTED
		for state in ["normal", "hover", "pressed"]:
			button.add_theme_stylebox_override(state, style)

func _select_palette(index: int) -> void:
	GameSettings.selected_palette = index
	for i in color_grid.get_child_count():
		color_grid.get_child(i).selected = i == index
		color_grid.get_child(i).queue_redraw()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

class ColorPaletteButton extends BaseButton:
	var palette: Array = []
	var selected := false

	func _draw() -> void:
		var rect := Rect2(Vector2(2, 2), size - Vector2(4, 4))
		for i in palette.size():
			var style := UI.box(palette[i], 0)
			if i == 0:
				style.corner_radius_top_left = 12
				style.corner_radius_bottom_left = 12
			if i == palette.size() - 1:
				style.corner_radius_top_right = 12
				style.corner_radius_bottom_right = 12
			var width := rect.size.x / palette.size()
			draw_style_box(style, Rect2(rect.position + Vector2(i * width, 0), Vector2(width, rect.size.y)))
		if selected:
			var outline := UI.box(Color.TRANSPARENT, 12)
			outline.set_border_width_all(4)
			outline.border_color = UI.SELECTED
			draw_style_box(outline, rect)