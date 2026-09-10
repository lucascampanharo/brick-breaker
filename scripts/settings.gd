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
# PADRÕES DE BLOCOS
# ============================================================

const BLOCK_PATTERNS := [
	"3×4", "4×4", "5×4", "6×4", "3×5",
	"4×5", "5×5", "6×5", "3×6", "4×6",
	"5×6", "6×6", "3×7", "4×7", "5×7",
	"6×7", "3×8", "4×8", "5×8", "6×8"
]

var selected_pattern := "5×6"


# ============================================================
# PALETAS DE CORES
# ============================================================

const COLOR_PALETTES := [
	[
		Color("A61E35"),
		Color("F13A1D")
	],

	[
		Color("003B00"),
		Color("286B0A")
	],

	[
		Color("F477B5"),
		Color("FFE18A")
	],

	[
		Color("B8C584"),
		Color("8D7C52"),
		Color("E7A17F")
	],

	[
		Color("652052"),
		Color("B51E4A"),
		Color("E8784D")
	],

	[
		Color("C6D1D8"),
		Color("E5E2D8"),
		Color("75947D")
	],

	[
		Color("32110D"),
		Color("8C0B08"),
		Color("E63114")
	],

	[
		Color("59D9D1"),
		Color("F0EA1D"),
		Color("FFB36A")
	],

	[
		Color("E98921"),
		Color("F5BB29"),
		Color("FFE98C")
	]
]

var selected_palette := 8


# ============================================================
# REFERÊNCIAS
# ============================================================

var pattern_grid: GridContainer
var color_grid: GridContainer


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready() -> void:

	set_anchors_preset(
		Control.PRESET_FULL_RECT
	)

	_build_screen()


# ============================================================
# CONSTRÓI A TELA
# ============================================================

func _build_screen() -> void:

	# --------------------------------------------------------
	# TÍTULO
	# --------------------------------------------------------

	var title := Label.new()

	title.text = "Configurações"

	title.position = Vector2(0, 65)
	title.size = Vector2(720, 80)

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	title.add_theme_font_size_override(
		"font_size",
		52
	)

	title.add_theme_color_override(
		"font_color",
		COLOR_TEXT
	)

	add_child(title)


	# --------------------------------------------------------
	# TÍTULO DOS PADRÕES
	# --------------------------------------------------------

	var pattern_title := Label.new()

	pattern_title.text = "Escolha o padrão de blocos:"

	pattern_title.position = Vector2(0, 145)
	pattern_title.size = Vector2(720, 45)

	pattern_title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	pattern_title.add_theme_font_size_override(
		"font_size",
		30
	)

	pattern_title.add_theme_color_override(
		"font_color",
		COLOR_TEXT
	)

	add_child(pattern_title)


	# --------------------------------------------------------
	# SUBTÍTULO
	# --------------------------------------------------------

	var pattern_subtitle := Label.new()

	pattern_subtitle.text = "(linhas x colunas)"

	pattern_subtitle.position = Vector2(0, 180)
	pattern_subtitle.size = Vector2(720, 35)

	pattern_subtitle.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	pattern_subtitle.add_theme_font_size_override(
		"font_size",
		20
	)

	pattern_subtitle.add_theme_color_override(
		"font_color",
		COLOR_TEXT
	)

	add_child(pattern_subtitle)


	# --------------------------------------------------------
	# PAINEL DOS PADRÕES
	# --------------------------------------------------------

	var pattern_panel := PanelContainer.new()

	pattern_panel.position = Vector2(70, 215)
	pattern_panel.size = Vector2(580, 420)

	pattern_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style()
	)

	add_child(pattern_panel)


	# --------------------------------------------------------
	# GRID DOS PADRÕES
	# --------------------------------------------------------

	pattern_grid = GridContainer.new()

	pattern_grid.columns = 5

	pattern_grid.add_theme_constant_override(
		"h_separation",
		10
	)

	pattern_grid.add_theme_constant_override(
		"v_separation",
		10
	)

	pattern_grid.size_flags_horizontal = (
		Control.SIZE_SHRINK_CENTER
	)

	pattern_grid.size_flags_vertical = (
		Control.SIZE_SHRINK_CENTER
	)

	pattern_panel.add_child(pattern_grid)


	for pattern in BLOCK_PATTERNS:

		_create_pattern_button(pattern)


	# --------------------------------------------------------
	# TÍTULO DAS CORES
	# --------------------------------------------------------

	var color_title := Label.new()

	color_title.text = "Escolha o padrão de cores:"

	color_title.position = Vector2(0, 675)
	color_title.size = Vector2(720, 50)

	color_title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	color_title.add_theme_font_size_override(
		"font_size",
		30
	)

	color_title.add_theme_color_override(
		"font_color",
		COLOR_TEXT
	)

	add_child(color_title)


	# --------------------------------------------------------
	# PAINEL DAS CORES
	# --------------------------------------------------------

	var color_panel := PanelContainer.new()

	color_panel.position = Vector2(70, 725)
	color_panel.size = Vector2(580, 345)

	color_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style()
	)

	add_child(color_panel)


	# --------------------------------------------------------
	# GRID DAS CORES
	# --------------------------------------------------------

	color_grid = GridContainer.new()

	color_grid.columns = 3

	color_grid.add_theme_constant_override(
		"h_separation",
		12
	)

	color_grid.add_theme_constant_override(
		"v_separation",
		12
	)

	color_grid.size_flags_horizontal = (
		Control.SIZE_SHRINK_CENTER
	)

	color_grid.size_flags_vertical = (
		Control.SIZE_SHRINK_CENTER
	)

	color_panel.add_child(color_grid)


	for i in range(COLOR_PALETTES.size()):

		_create_color_button(i)


	# --------------------------------------------------------
	# BOTÃO VOLTAR
	# --------------------------------------------------------

	var back_button := Button.new()

	back_button.name = "BackButton"

	back_button.text = "←"

	back_button.position = Vector2(40, 1125)
	back_button.size = Vector2(80, 80)

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


# ============================================================
# BOTÃO DE PADRÃO
# ============================================================

func _create_pattern_button(
	pattern: String
) -> void:

	var button := Button.new()

	button.text = pattern

	button.custom_minimum_size = Vector2(
		90,
		70
	)

	button.focus_mode = Control.FOCUS_NONE

	button.add_theme_font_size_override(
		"font_size",
		25
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
			pattern == selected_pattern
		)
	)

	button.add_theme_stylebox_override(
		"hover",
		_make_pattern_style(
			pattern == selected_pattern
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

	selected_pattern = pattern

	print(
		"Padrão de blocos: ",
		selected_pattern
	)


	for child in pattern_grid.get_children():

		if child is Button:

			var button := child as Button

			var selected := (
				button.text == selected_pattern
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
		170,
		75
	)

	button.palette = COLOR_PALETTES[index]

	button.selected = (
		index == selected_palette
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

	selected_palette = index

	print(
		"Paleta selecionada: ",
		selected_palette + 1
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
				i == selected_palette
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

				draw_rect(
					color_rect,
					palette[i]
				)


		# ----------------------------------------------------
		# BORDA DA PALETA SELECIONADA
		# ----------------------------------------------------

		if selected:

			draw_rect(
				rect,
				COLOR_SELECTED,
				false,
				4.0
			)


	func _make_background() -> StyleBoxFlat:

		var style := StyleBoxFlat.new()

		style.bg_color = Color("D9D9D9")

		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12

		return style