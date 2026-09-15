extends Control


# ============================================================
# CORES DA INTERFACE
# ============================================================

const COLOR_TEXT := Color("76ABAE")
const COLOR_PANEL := Color("303841")
const COLOR_BUTTON := Color("D9D9D9")
const COLOR_BUTTON_TEXT := Color("76ABAE")
const COLOR_SELECTED := Color("F15A3A")


# ============================================================
# REFERÊNCIAS
# ============================================================

var pattern_grid: GridContainer
var color_grid: GridContainer


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready() -> void:

	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Arial"])
	font.font_weight = 700
	theme = Theme.new()
	theme.default_font = font

	_build_screen()


# ============================================================
# CONSTRÓI A TELA
# ============================================================

func _build_screen() -> void:
	var center := CenterContainer.new()
	center.name = "Center"
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var layout := VBoxContainer.new()
	layout.name = "Layout"
	layout.add_theme_constant_override("separation", 24)
	center.add_child(layout)
	layout.add_child(_build_heading("Configurações", 52))

	var pattern_content := _build_section(layout, "PatternPanel")
	var pattern_heading := VBoxContainer.new()
	pattern_heading.add_theme_constant_override("separation", 0)
	pattern_content.add_child(pattern_heading)
	pattern_heading.add_child(_build_heading("Escolha o padrão de blocos:", 36))
	pattern_heading.add_child(_build_heading("(linhas x colunas)", 26))
	pattern_grid = GridContainer.new()
	pattern_grid.columns = 5
	pattern_grid.add_theme_constant_override("h_separation", 10)
	pattern_grid.add_theme_constant_override("v_separation", 10)
	pattern_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pattern_content.add_child(pattern_grid)
	for pattern in GameSettings.BLOCK_PATTERNS:
		_create_pattern_button(pattern)

	var color_content := _build_section(layout, "ColorPanel")
	color_content.add_child(_build_heading("Escolha o padrão de cores:", 36))
	color_grid = GridContainer.new()
	color_grid.columns = 3
	color_grid.add_theme_constant_override("h_separation", 12)
	color_grid.add_theme_constant_override("v_separation", 12)
	color_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	color_content.add_child(color_grid)
	for i in range(GameSettings.COLOR_PALETTES.size()):
		_create_color_button(i)

	var back_button := Button.new()

	back_button.name = "BackButton"

	back_button.icon = preload("res://assets/icons/back.svg")
	back_button.expand_icon = true
	back_button.add_theme_constant_override("icon_max_width", 64)


	back_button.focus_mode = Control.FOCUS_NONE

	back_button.add_theme_font_size_override(
		"font_size",
		42
	)

	back_button.add_theme_color_override(
		"font_color",
		COLOR_TEXT
	)

	back_button.add_theme_stylebox_override(
		"normal",
		_make_back_style()
	)

	back_button.add_theme_stylebox_override(
		"hover",
		_make_back_style()
	)

	back_button.add_theme_stylebox_override(
		"pressed",
		_make_back_style()
	)

	back_button.pressed.connect(
		_on_back_pressed
	)

	add_child(back_button)
	back_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	back_button.offset_left = 44
	back_button.offset_top = -90
	back_button.offset_right = 108
	back_button.offset_bottom = -26


# ============================================================
# COMPONENTES DO LAYOUT
# ============================================================

func _build_heading(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", COLOR_TEXT)
	return label


func _build_section(layout: VBoxContainer, section_name: String) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.name = section_name
	panel.custom_minimum_size.x = 620
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	layout.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 24)
	panel.add_child(content)
	return content


# ============================================================
# BOTÃO DE PADRÃO
# ============================================================

func _create_pattern_button(
	pattern: String
) -> void:

	var button := Button.new()

	button.text = pattern

	button.custom_minimum_size = Vector2(
		100,
		82
	)

	button.focus_mode = Control.FOCUS_NONE

	button.add_theme_font_size_override(
		"font_size",
		36
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
		_make_pattern_style(
			pattern == GameSettings.selected_pattern
		)
	)

	button.add_theme_stylebox_override(
		"hover",
		_make_pattern_style(
			pattern == GameSettings.selected_pattern
		)
	)

	button.add_theme_stylebox_override(
		"pressed",
		_make_pattern_style(true)
	)

	button.pressed.connect(
		func():
			_select_pattern(pattern)
	)

	pattern_grid.add_child(button)


# ============================================================
# SELECIONA PADRÃO DE BLOCO
# ============================================================

func _select_pattern(
	pattern: String
) -> void:

	GameSettings.selected_pattern = pattern

	print(
		"Padrão de blocos: ",
		GameSettings.selected_pattern
	)


	for child in pattern_grid.get_children():

		if child is Button:

			var button := child as Button

			var selected := (
				button.text == GameSettings.selected_pattern
			)

			button.add_theme_stylebox_override(
				"normal",
				_make_pattern_style(selected)
			)

			button.add_theme_stylebox_override(
				"hover",
				_make_pattern_style(selected)
			)

			button.add_theme_stylebox_override(
				"pressed",
				_make_pattern_style(true)
			)


# ============================================================
# BOTÃO DE PALETA
# ============================================================

func _create_color_button(
	index: int
) -> void:

	var button := ColorPaletteButton.new()

	button.custom_minimum_size = Vector2(
		176,
		84
	)

	button.palette = GameSettings.COLOR_PALETTES[index]

	button.selected = (
		index == GameSettings.selected_palette
	)

	button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	button.pressed.connect(
		func():
			_select_palette(index)
	)

	color_grid.add_child(button)


# ============================================================
# SELECIONA PALETA
# ============================================================

func _select_palette(
	index: int
) -> void:

	GameSettings.selected_palette = index

	print(
		"Paleta selecionada: ",
		GameSettings.selected_palette + 1
	)


	for i in range(
		color_grid.get_child_count()
	):

		var button := (
			color_grid.get_child(i)
			as ColorPaletteButton
		)

		if button:

			button.selected = (
				i == GameSettings.selected_palette
			)

			button.queue_redraw()


# ============================================================
# ESTILO DOS BOTÕES DE BLOCOS
# ============================================================

func _make_pattern_style(
	selected: bool
) -> StyleBoxFlat:

	var style := StyleBoxFlat.new()

	style.bg_color = COLOR_BUTTON

	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14

	if selected:

		style.border_width_left = 4
		style.border_width_top = 4
		style.border_width_right = 4
		style.border_width_bottom = 4

		style.border_color = COLOR_SELECTED

	return style


# ============================================================
# ESTILO DOS PAINÉIS
# ============================================================

func _make_panel_style() -> StyleBoxFlat:

	var style := StyleBoxFlat.new()

	style.bg_color = COLOR_PANEL

	style.corner_radius_top_left = 30
	style.corner_radius_top_right = 30
	style.corner_radius_bottom_left = 30
	style.corner_radius_bottom_right = 30

	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 20
	style.content_margin_bottom = 20

	return style


# ============================================================
# ESTILO DO BOTÃO VOLTAR
# ============================================================

func _make_back_style() -> StyleBoxFlat:

	var style := StyleBoxFlat.new()

	style.bg_color = Color(
		0,
		0,
		0,
		0
	)

	return style


# ============================================================
# VOLTAR AO MENU
# ============================================================

func _on_back_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://scenes/main_menu.tscn"
	)


# ============================================================
# CLASSE PARA DESENHAR AS PALETAS
# ============================================================

class ColorPaletteButton extends Button:

	var palette: Array = []

	var selected: bool = false


	func _ready() -> void:

		flat = true

		clip_contents = true

		mouse_default_cursor_shape = (
			Control.CURSOR_POINTING_HAND
		)


	func _draw() -> void:

		var rect := Rect2(
			2,
			2,
			size.x - 4,
			size.y - 4
		)


		# ----------------------------------------------------
		# FUNDO
		# ----------------------------------------------------

		draw_style_box(
			_make_background(),
			rect
		)


		# ----------------------------------------------------
		# CORES DA PALETA
		# ----------------------------------------------------

		if palette.size() > 0:

			var color_width := (
				rect.size.x / palette.size()
			)


			for i in range(
				palette.size()
			):

				var color_rect := Rect2(
					rect.position.x
					+ i * color_width,

					rect.position.y,

					color_width,

					rect.size.y
				)

				var style := StyleBoxFlat.new()
				style.bg_color = palette[i]
				if i == 0:
					style.corner_radius_top_left = 12
					style.corner_radius_bottom_left = 12
				if i == palette.size() - 1:
					style.corner_radius_top_right = 12
					style.corner_radius_bottom_right = 12
				draw_style_box(style, color_rect)


		# ----------------------------------------------------
		# BORDA DA PALETA SELECIONADA
		# ----------------------------------------------------

		if selected:

			var outline := _make_background()
			outline.bg_color = Color.TRANSPARENT
			outline.border_color = COLOR_SELECTED
			outline.set_border_width_all(4)
			draw_style_box(outline, rect)


	func _make_background() -> StyleBoxFlat:

		var style := StyleBoxFlat.new()

		style.bg_color = Color("D9D9D9")

		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12

		return style
